import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.imageio.ImageIO;

public class Fighter extends GameObject {
	//========================================================================================================Properties
	private int massBar, nrgBar;
	private int maxMassBar, maxNRGBar;
	private String fileName, fileNameFlip;
	private Fighters type;
	private boolean flip;

	//======================================================================================================Constructors
	public Fighter(double x, double y, Fighters type) {
		this(x, y, type.getWidth(), type.getHeight(), type.getxSpeed(), 0, type, type.getMaxMassBar()/2, type.getMaxNRGBar()/2);
	}
	// Workhorse Constructor
	public Fighter(double x, double y, double width, double height, double xSpeed, double ySpeed, Fighters type, int massBar, int nrgBar) {
		super(x, y, width, height, xSpeed, ySpeed);
		setType(type);
		setMassBar(massBar);
		setNrgBar(nrgBar);
	}
	// Copy Constructor
	public Fighter(Fighter f) {
		this(f.getX(), f.getY(), f.getWidth(), f.getHeight(), f.getxSpeed(), f.getySpeed(), f.getType(), f.getMassBar(), f.getNrgBar());
	}
	
	//===========================================================================================================Methods
	public Fighter clone() {
		return new Fighter(this);
	}
	
	// Compare by x
	public double compareTo(Fighter f) {
		return getX() - f.getX();
	}
	
	@Override
	public boolean equals(Object o) {
		if ( o instanceof Fighter ) {
			Fighter f = (Fighter) o;
			return f.getX() == getX() && f.getY() == getY() && f.getWidth() == getWidth() && f.getHeight() == getHeight()
					&& f.getxSpeed() == getxSpeed() && f.getySpeed() == getySpeed() && f.getType() == getType() &&
					f.getMassBar() == getMassBar() && f.getNrgBar() == getNrgBar();
		}
		return false;
	}
	// Move Fighter left and right
	public void move(boolean toRight) {
		double newLocation = getX() + (toRight ? 1:-1)*getxSpeed();
		if (newLocation < 0 || newLocation > sw-getWidth())
			return;
		super.x = (int) (newLocation);
	}
	
	public void slide() {
		
	}
	
	// Shoot Energy
	public void shoot(ArrayList<Bullet> bullets, int maxBullets) {
		if ( bullets.size() > maxBullets || nrgBar <= 0 )
			return;
		setNrgBar(getNrgBar() - 100);
		bullets.add(new Bullet(getX(), getY(), 20,20,0,10));
	}
	
	@Override
	public void draw(Graphics g) {
		// Draw Fighter
	    BufferedImage buffImg = new BufferedImage((int) getWidth(), (int) getHeight(), BufferedImage.TYPE_INT_ARGB);
		Image img = null;
		try {
			if ( !isFlip() )
				buffImg = ImageIO.read(new File(getFileName()));
			else
				buffImg = ImageIO.read(new File(getFileNameFlip()));
		} catch (IOException e) {
			System.out.println("ERROR");
			e.printStackTrace();
		}
		Graphics2D g2d = (Graphics2D) (g);
		g2d.drawImage(buffImg, (int) getX(), (int) getY(), (int) getWidth(), (int) getHeight(), null);
		
		g.setFont(new Font("default", Font.BOLD, 12));
		// Draw Mass Bar
		g.setColor(Color.green);
		g.fillRect(80, sh-80, getMassBar(), 10);
		g.setColor(Color.BLACK);
		g.drawString("Mass Bar:", 20, sh-70);
		g.drawRect(80, sh-80, getMaxMassBar(), 10);
		
		// Draw Energy Bar
		g.setColor(new Color(102,0,102));
		g.fillRect(80, sh-60, getNrgBar(), 10);
		g.setColor(Color.BLACK);
		g.drawString("Energy Bar:", 15, sh-50);
		g.drawRect(80, sh-60, getMaxNRGBar(), 10);
	}
	
	//===================================================================================================Getters/Setters	
	public int getMassBar() 			{   return massBar; 	 				}
	public void setMassBar(int massBar) {
		if ( massBar > getType().getMaxMassBar() )
			return;
		this.massBar = massBar;
	}
	public int getNrgBar() 				{   return nrgBar;  	 				}
	public void setNrgBar(int nrgBar) {
		if ( nrgBar > getType().getMaxNRGBar() )
			return;
		this.nrgBar = nrgBar;
	}
	public boolean isFlip() 			{   return flip;   						}
	public void setFlip(boolean flip) 	{   this.flip = flip;   				}
	public int getMaxMassBar() 			{	return getType().getMaxMassBar();	}
	public int getMaxNRGBar() 			{   return getType().getMaxNRGBar();	}
	public String getFileName()			{	return getType().getFileName();		}
	public String getFileNameFlip() 	{	return getType().getFileNameFlip();	}
	public Fighters getType() 			{	return type;						}
	public void setType(Fighters type) {
		if ( type != Fighters.Cowboy && type != Fighters.Mouse && type != Fighters.Scientist )
			return;
		this.type = type;
	}
	
}
