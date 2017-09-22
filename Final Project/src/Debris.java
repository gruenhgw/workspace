import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Image;
import java.awt.Transparency;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.imageio.ImageIO;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;

public class Debris extends GameObject implements Drawable, Explodable {
	private static final GraphicsConfiguration GFX_CONFIG = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
	BufferedImage buffImg1 = new BufferedImage(1005, 1005, BufferedImage.TYPE_INT_ARGB);
	//======================================================================================================Constructors
	// Workhorse Constructor
	public Debris(double x, double y, double width, double height, double xSpeed, double ySpeed) {
		super(x, y, width, height, xSpeed, ySpeed);
	}

	// Copy Constructor
	public Debris (Debris d) {
		this(d.getX(), d.getY(), d.getWidth(), d.getHeight(), d.getxSpeed(), d.getySpeed());
	}

	//===========================================================================================================Methods
	public Debris clone() {
		return new Debris(this);
	}

	// Compares size
	public double compareTo(Debris d) {
		return (getWidth() + getHeight()) - (d.getWidth() + d.getHeight());
	}

	@Override
	public boolean equals(Object o) {
		if ( o instanceof Debris ) {
			Debris d = (Debris) o;
			return this.getX() == d.getX() && this.getY() == d.getY() && this.getWidth() == d.getWidth() &&
					this.getHeight() == d.getHeight() && this.getxSpeed() == d.getxSpeed() &&
					this.getySpeed() == d.getySpeed();
		}
		return false;
	}

	@Override
	public String toString() {
		return "Debris [x=" + getX() + ", y=" + getY() + ", width=" + getWidth() + ", height=" + getHeight() + 
				", xSpeed= " + getxSpeed() + "ySpeed= " + getySpeed()+ "]";
	}

	// Moves Debris, but if it moves off screen or hits another debris with a great difference in momentum,
	// it returns false. 
	public boolean move(ArrayList<Debris> debrises, Fighter f) {
		super.x = (int) (getX() + getxSpeed());
		super.y = (int) (getY() + getySpeed());
		for ( Debris d : debrises ) {
			// Returns false if debris crashes with another debris with a great difference in momentum
			if ( this.intersects(d) && d.getMomentum() - this.getMomentum() > 15000 ) {
				try {
					Clip clip = AudioSystem.getClip();
					clip.open(AudioSystem.getAudioInputStream(new File("pop.wav")));
					clip.start();
				}
				catch (Exception exc) {
					exc.printStackTrace(System.out);
				}
				f.setNrgBar(f.getNrgBar() + 50);
				return false;
			}
		}

		// Returns false if the debris moves of screen, otherwise true.
		if(getX() > sw) {
			return false;
		} else if(getX() < -getWidth()) {
			return false;
		} else if (getY() > sh) {
			return false;
		}
		else {
			return true;
		}
	}

	@Override
	public void draw(Graphics g) {
		BufferedImage buffImg = new BufferedImage((int) getWidth(), (int) getHeight(), BufferedImage.TYPE_INT_ARGB);
		Image img = null;
		try {
			buffImg = ImageIO.read(new File("Debris_0.png"));
		} catch (IOException e) {
			System.out.println("ERROR");
			e.printStackTrace();
		}
		Graphics2D g2d = (Graphics2D) (g);
		g2d.drawImage(buffImg, (int) getX(), (int) getY(), (int) getWidth(), (int) getHeight(), null);
		//		g2d.dispose();
	}

	public void loadExplode() {
		try {
			buffImg1 = ImageIO.read(new File("explosion1Short.png"));
//			buffImg1 = null;
		} catch (IOException e) {
			System.out.println("Can't load explode");
		}
	}

	public void drawExplode(Graphics g, int frame) {
		//		GraphicsEnvironment env = GraphicsEnvironment.getLocalGraphicsEnvironment();
		//		GraphicsDevice device = env.getDefaultScreenDevice();
		//		GraphicsConfiguration config = device.getDefaultConfiguration();
		//		BufferedImage buffImg = config.createCompatibleImage((int) getWidth(), (int) getHeight(), Transparency.TRANSLUCENT);
		//	    BufferedImage buffImg = new BufferedImage((int) getWidth(), (int) getHeight(), BufferedImage.TYPE_INT_ARGB);
		//		Image img = null;
		long tStart = System.currentTimeMillis();
		int x = 249*((frame-1)%4);
		int y = 238*((frame-1)/4);
		System.out.println("Trying to draw: x = " + (x+249));
		System.out.println(buffImg1.getWidth());
		System.out.println("Trying to draw: y = " + (y+238));
		System.out.println(buffImg1.getHeight());
		BufferedImage buffImg2 = buffImg1.getSubimage(x, y, 249, 238);
		Graphics2D g2d = (Graphics2D) (g);
		g2d.drawImage(buffImg2, (int) getX(), (int) getY(), (int) getWidth(), (int) getHeight(), null);
		g2d.dispose();
		System.out.println(System.currentTimeMillis()-tStart);
	}

}
