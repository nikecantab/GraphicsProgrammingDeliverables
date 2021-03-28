using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;
using System;
using System.Collections.Generic;
using System.Text;

namespace GraphicsProgramming
{
	class Lesson1 : Lesson
	{
		static Color col1 = new Color(150,150,150);
		static Color col2 = new Color(250,250,250);

		VertexPositionColor[] vertices = {
			//+z
			new VertexPositionColor( new Vector3( -0.5f, 0.5f, 0.5f ), col2 ),		//0 UL
			new VertexPositionColor( new Vector3( 0.5f, -0.5f, 0.5f ), col1),	//1	DR
			new VertexPositionColor( new Vector3( -0.5f, -0.5f, 0.5f ), col1),	//2 DL
			new VertexPositionColor( new Vector3( 0.5f, 0.5f, 0.5f ), col2 ),	//3 UR
			
			//-z
			new VertexPositionColor( new Vector3( -0.5f, 0.5f, -0.5f ), col2 ),	//4 UL
			new VertexPositionColor( new Vector3( 0.5f, -0.5f, -0.5f ), col1),	//5 DR 
			new VertexPositionColor( new Vector3( -0.5f, -0.5f, -0.5f ), col1),	//6 DL
			new VertexPositionColor( new Vector3( 0.5f, 0.5f, -0.5f ), col2 )	//7 UR
		};

		int[] indices = {
			//FRONT
			//triangle 1
			0, 1, 2,
			//triangle 2
			0, 3, 1,

			//BACK
			//triangle 1
			4, 6, 5,
			//triangle 2
			4, 5, 7,

			//RIGHT
			//triangle 1
			5, 3, 7,
			//triangle 2
			5, 1, 3,

			//LEFT
			//triangle 1
			2, 4, 0,
			//triangle 2
			2, 6, 4,

			//UP
			//triangle 1
			3, 4, 7,
			//triangle 2
			3, 0, 4,

			//DOWN
			//triangle 1
			2, 5, 6,
			//triangle 2
			2, 1, 5,
		};

		BasicEffect effect;

		public override void LoadContent(ContentManager Content, GraphicsDeviceManager graphics, SpriteBatch spriteBatch)
		{
			effect = new BasicEffect(graphics.GraphicsDevice);
		}

		public override void Draw(GameTime gameTime, GraphicsDeviceManager graphics, SpriteBatch spriteBatch)
		{
			GraphicsDevice device = graphics.GraphicsDevice;
			device.Clear(Color.Black);

			effect.World = Matrix.Identity 
				* Matrix.CreateRotationY((float)gameTime.TotalGameTime.TotalSeconds)
				* Matrix.CreateRotationX((float)gameTime.TotalGameTime.TotalSeconds)
				* Matrix.CreateTranslation(
					MathF.Sin((float)gameTime.TotalGameTime.TotalSeconds), 
					MathF.Cos((float)gameTime.TotalGameTime.TotalSeconds), 
					MathF.Sin((float)gameTime.TotalGameTime.TotalSeconds * 3)/2);
			effect.View = Matrix.CreateLookAt(-Vector3.Forward * 5, Vector3.Zero, Vector3.Up);
			effect.Projection = Matrix.CreatePerspectiveFieldOfView((MathF.PI / 180f) * 65f, device.Viewport.AspectRatio, 0.1f, 100f);

			effect.VertexColorEnabled = true;
			foreach (EffectPass pass in effect.CurrentTechnique.Passes)
			{
				pass.Apply();
				device.DrawUserIndexedPrimitives(PrimitiveType.TriangleList, vertices, 0, vertices.Length, indices, 0, indices.Length / 3);
			}
		}
	}
}