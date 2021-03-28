using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;

namespace GraphicsProgramming
{
	class LiveLesson3 : Lesson
	{
		private Effect myEffect;
		Texture2D clouds, night, day, moon, mars, deimos, phobos, black;
		TextureCube sky;
		Model sphere, cube;
		Vector3 LightPosition = Vector3.Right * 2 + Vector3.Up * 2;
		Vector3 LightColor = new Vector3(1.0f, 1.0f, 1.0f);

		float yaw, pitch, zoom, prevZoom;
		int prevX, prevY; //prevZoom;

        public override void Update(GameTime gameTime)
        {
			MouseState mState = Mouse.GetState();

			if(mState.LeftButton == ButtonState.Pressed)
            {
				//update yaw and pitch
				yaw += (mState.X - prevX) * 0.01f;
				pitch += (mState.Y - prevY) * 0.01f;

				pitch = MathF.Min(MathF.Max(pitch, -MathF.PI * 0.49f), MathF.PI * 0.49f);
			}
			//zoom -= (mState.ScrollWheelValue - prevZoom) * 0.01f;

			zoom -= (mState.ScrollWheelValue - prevZoom) * 0.01f;
			prevZoom = mState.ScrollWheelValue;


			prevX = mState.X;
			prevY = mState.Y;

			//prevZoom = mState.ScrollWheelValue;
		}


        public override void LoadContent(ContentManager Content, GraphicsDeviceManager graphics, SpriteBatch spriteBatch)
		{
			myEffect = Content.Load<Effect>("LiveLesson3");

			clouds = Content.Load<Texture2D>("clouds");
			night = Content.Load<Texture2D>("night");
			day = Content.Load<Texture2D>("day");
			moon = Content.Load<Texture2D>("2k_moon");
            sky = Content.Load<TextureCube>("sky_cube");
			mars = Content.Load<Texture2D>("2k_mars");
			deimos = Content.Load<Texture2D>("deimos2k");
			phobos = Content.Load<Texture2D>("phobos2k");
			black = Content.Load<Texture2D>("black");

            sphere = Content.Load<Model>("uv_sphere");

			foreach (ModelMesh mesh in sphere.Meshes)
			{
				foreach (ModelMeshPart meshPart in mesh.MeshParts)
				{
					meshPart.Effect = myEffect;
				}
			}

			cube = Content.Load<Model>("cube");
			foreach (ModelMesh mesh in cube.Meshes)
			{
				foreach (ModelMeshPart meshPart in mesh.MeshParts)
				{
					meshPart.Effect = myEffect;
				}
			}
		}

		public override void Draw(GameTime gameTime, GraphicsDeviceManager graphics, SpriteBatch spriteBatch)
		{
			GraphicsDevice device = graphics.GraphicsDevice;

			float time = (float)gameTime.TotalGameTime.TotalSeconds;
			LightPosition = Vector3.Left * 200; //(MathF.Cos(time), 0, MathF.Sin(time)) * 200;

			Vector3 cameraPos = -Vector3.Forward * zoom + Vector3.Up * 5;// + Vector3.Right * 5;
			cameraPos = Vector3.Transform(cameraPos, Quaternion.CreateFromYawPitchRoll(yaw, pitch, 0));
			//add zoom

			Matrix World = Matrix.CreateWorld(Vector3.Zero, Vector3.Forward, Vector3.Up);
			Matrix View = Matrix.CreateLookAt(cameraPos, Vector3.Zero, Vector3.Up);

			myEffect.Parameters["World"].SetValue(World);
			myEffect.Parameters["View"].SetValue(View);
			myEffect.Parameters["Projection"].SetValue(Matrix.CreatePerspectiveFieldOfView((MathF.PI / 180f) * 25f, device.Viewport.AspectRatio, 0.001f, 1000f));

			myEffect.Parameters["SkyColor"].SetValue(new Vector3(.529f, 0.808f, 0.992f));

			myEffect.Parameters["DayTex"].SetValue(day);
            myEffect.Parameters["NightTex"].SetValue(night);
			myEffect.Parameters["CloudsTex"].SetValue(clouds);
			myEffect.Parameters["MoonTex"].SetValue(moon);
			myEffect.Parameters["SkyTex"].SetValue(sky);

			myEffect.Parameters["LightPosition"].SetValue(LightPosition);
			myEffect.Parameters["CameraPosition"].SetValue(cameraPos);

			myEffect.Parameters["LightColor"].SetValue(LightColor);
			myEffect.Parameters["Specularity"].SetValue(0.1f);

			myEffect.Parameters["Time"].SetValue(time);

			myEffect.CurrentTechnique.Passes[0].Apply();

			device.Clear(Color.Black);

			//Sky
			myEffect.CurrentTechnique = myEffect.Techniques["Sky"];
			device.DepthStencilState = DepthStencilState.None;
			device.RasterizerState = RasterizerState.CullNone;
			RenderModel(cube, Matrix.CreateTranslation(cameraPos));

			device.RasterizerState = RasterizerState.CullCounterClockwise;
			device.DepthStencilState = DepthStencilState.Default;

            //re-setting parameters because im too lazy to make new samplers for each texture

            //Mars
            //atmosphere ON
   //         myEffect.Parameters["DayTex"].SetValue(mars);
   //         myEffect.Parameters["NightTex"].SetValue(black);
			//myEffect.Parameters["SkyColor"].SetValue(new Vector3(0.992f, 0.808f, .529f));
   //         myEffect.CurrentTechnique = myEffect.Techniques["Earth"];

            //atmosphere OFF
            myEffect.Parameters["MoonTex"].SetValue(mars);
            myEffect.CurrentTechnique = myEffect.Techniques["Moon"];

            RenderModel(sphere, Matrix.CreateScale(0.01f)
						* Matrix.CreateRotationZ(time)
						* Matrix.CreateRotationY(MathF.PI / 180 * 25)
						* World);

			//Deimos
			myEffect.Parameters["MoonTex"].SetValue(deimos);
			myEffect.CurrentTechnique = myEffect.Techniques["Moon"];
			RenderModel(sphere, Matrix.CreateTranslation(Vector3.Down * (23 + 4)) * Matrix.CreateScale(0.002f) * Matrix.CreateRotationZ( time * 0.75f) * World);

			//Phobos
			myEffect.Parameters["MoonTex"].SetValue(phobos);
			myEffect.CurrentTechnique = myEffect.Techniques["Moon"];
			RenderModel(sphere, Matrix.CreateTranslation(Vector3.Down * (9 + 4)) * Matrix.CreateScale(0.001f) * Matrix.CreateRotationZ( time * 3.0f) * World);


			////Earth
			//myEffect.CurrentTechnique = myEffect.Techniques["Earth"];
			//RenderModel(sphere, Matrix.CreateScale(0.01f) 
			//			* Matrix.CreateRotationZ(time) 
			//			* Matrix.CreateRotationY(MathF.PI / 180 * 23)
			//			* World);

			////Moon
			//myEffect.CurrentTechnique = myEffect.Techniques["Moon"];
			//RenderModel(sphere, Matrix.CreateTranslation(Vector3.Down * 8) * Matrix.CreateScale(0.0033f) * Matrix.CreateRotationZ(time - time * 0.333f) * World);
		}

		void RenderModel(Model m, Matrix parentMatrix)
		{
			Matrix[] transforms = new Matrix[m.Bones.Count];
			m.CopyAbsoluteBoneTransformsTo(transforms);

			myEffect.CurrentTechnique.Passes[0].Apply();
			
			foreach( ModelMesh mesh in m.Meshes)
            {
				myEffect.Parameters["World"].SetValue(parentMatrix * transforms[mesh.ParentBone.Index]);

				mesh.Draw();
            }
		}

		void ApplyShader(Effect e)
        {

        }

	}
}
