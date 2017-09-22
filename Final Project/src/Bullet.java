import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.imageio.ImageIO;

public class Bullet extends GameObject {
	//======================================================================================================Constructors
	// Workhorse Constructor
	public Bullet(double x, double y, double width, double height, double xSpeed, double ySpeed) {
		super(x, y, width, height, xSpeed, ySpeed);
	}
	
	//===========================================================================================================Methods
	public boolean move() {
		if ( getY() + getHeight() < 0 )
			return false;
		super.y = (int) (getY() - getySpeed());
		return true;
	}
	
	@Override
	public void draw(Graphics g) {
	    BufferedImage buffImg = new BufferedImage((int) getWidth(), (int) getHeight(), BufferedImage.TYPE_INT_ARGB);
		Image img = null;
		try {
			buffImg = ImageIO.read(new File("Bullet.png"));
		} catch (IOException e) {
			System.out.println("ERROR");
			e.printStackTrace();
		}
		Graphics2D g2d = (Graphics2D) (g);
		g2d.drawImage(buffImg, (int) getX(), (int) getY(), (int) getWidth(), (int) getHeight(), null);
	}

}
