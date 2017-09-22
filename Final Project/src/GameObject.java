import java.awt.Graphics;
import java.awt.Point;
import java.awt.Rectangle;
import java.io.File;

import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;

public abstract class GameObject extends Rectangle implements Drawable {
	//========================================================================================================Properties
	public static int sw, sh; 
	public final static double minimumWidth = 10, minimumHeight = 10, maximumWidth = 200, maximumHeight = 200;

	private double xSpeed, ySpeed, momentum;
	
	//======================================================================================================Constructors
	// Workhorse Constructor
	public GameObject(double x, double y, double width, double height, double xSpeed, double ySpeed) {
		super((int) x, (int) y, (int) width, (int) height);
		setxSpeed(xSpeed);
		setySpeed(ySpeed);
		setMomentum();
	}
	
	// Copy Constructor
	public GameObject(GameObject go) {
		this(go.getX(), go.getY(), go.getWidth(), go.getHeight(), go.getxSpeed(), go.getySpeed());
	}
	
	//===========================================================================================================Methods
	// Changes the Size of the GameObject and it's xSpeed and ySpeed in accordance with
	// the conservation of momentum (kinda, some balancing was done to make the game more fun).
	public void changeSize(Fighter f, boolean grow) {
		int change =  (int)  (.2 * getHeight())*(grow? 1:-1);
		if( f != null && (f.getMassBar() - change > f.getMaxMassBar() && !grow || f.getMassBar() + change <= 0 && grow)) {
			System.out.println("Bar limitation");
			return;
		}
		if ( getWidth() + change < minimumWidth || getHeight() + change < minimumHeight ||
				getWidth() + change > maximumHeight || getHeight() + change > maximumHeight)
			return;
		
		super.width = (int) (getWidth() + change);
		super.height = (int) (getHeight() + change);
		
		double momentumBefore = getMomentum();
		setMomentum();
		double momentumAfter = getMomentum();
		double changeInMomentum = momentumAfter - momentumBefore;

		setySpeed( getySpeed() - (changeInMomentum / (getWidth() * getHeight())) );
		if ( f != null )
			f.setMassBar(f.getMassBar() - change + (!grow ? 5:0));
	}
	
	//===================================================================================================Getters/Setters	
	public double getxSpeed() {   return xSpeed;   }
	public void setxSpeed(double xSpeed) {
		if ( xSpeed == 0 )
			return;
		this.xSpeed = xSpeed;
	}
	public double getySpeed() {   return ySpeed;   }
	public void setySpeed(double ySpeed) {
		if ( ySpeed < 1 )
			return;
		this.ySpeed = ySpeed;
	}
	public double getMomentum() {   return momentum;   }
	public void setMomentum() {   this.momentum = width*height*(xSpeed + ySpeed);   }
	
}
