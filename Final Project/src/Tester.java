import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Random;

import javax.imageio.ImageIO;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextArea;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import java.awt.GraphicsEnvironment;

public class Tester extends JPanel {

	ArrayList<Debris> debrises = new ArrayList();
	ArrayList<Fighter> fighters = new ArrayList();
	ArrayList<Bullet> bullets = new ArrayList();
	ArrayList<Debris> exploded = new ArrayList();
	ArrayList<Integer> explodedFrame = new ArrayList();
	boolean holdRight;
	boolean holdLeft;
	Fighter main = null;
	public static final int numDebrises = 25;
	public static final int maxBullets = 3;
	JFrame window = new JFrame("First Law");
	Timer tmr;
	Random rnd = new Random();
	public static final int groundLevel = 100;
	long tStart;

	public Tester() {
		// Introduction to the Game
		JOptionPane.showMessageDialog(null, 
				"This game operates on a couple of simple principles,\n	"
						+ "      1. The Conservation of Mass\n						"
						+ "      2. The Conservation of Momentum\n					"
						+ "      3. The Conservation of Energy\n					"
						+ "kind of like the real world does.\n						"
						+ "However, you have the ability to temporarily store\n		"
						+ "finite amount of energy and mass to use at your will.\n\n"	
						+ "							Controls:\n						"
						+ "Left Click to shrink an object.\n						"
						+ "Right Click to make an object grow.\n					"
						+ "Use 'a' and 'd' to move left and right.\n				"
						+ "Use 'w' to shoot an energy ball.\n						"
						+ "If you change the size of debris and they have a great\n	"
						+ "difference in  momentum, the debris will be converted\n	"
						+ "from mass to usable energy for you.\n\n					"
						+ "							Objective:\n					"
						+ "Getting hit by debris will kill you.\n					"
						+ "Try to stay alive as long as you can.\n					"
						+ "Oh and the game gets harder as you go on.\n\n			"
						+ "Click 'OK' to continue.									", "Welcome!", JOptionPane.INFORMATION_MESSAGE);
		// Background Game Music
		try {
			Clip clip = AudioSystem.getClip();
			clip.open(AudioSystem.getAudioInputStream(new File("SBTRKT - LAIKA.wav")));
			clip.start();
		}
		catch (Exception exc) {
			exc.printStackTrace(System.out);
		}

		// Setting up Game Window
		ImageIcon img = new ImageIcon("Debris_0.png");
		window.setIconImage(img.getImage());
		window.setBounds(500, 0, 700, 700);
		window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		window.getContentPane().add(this).setBackground(new Color(255, 80, 80));
		window.setVisible(false);
		window.setResizable(false);

		GameObject.sw = window.getWidth();
		GameObject.sh = window.getHeight();

		// Character Selection
		JTextArea charSelectText = new JTextArea("Please select your character\n"
				+ "Mass Bar    |	       600            |       500       |	500	\n"
				+ "Energy Bar |	       400            |       400       |	500	\n"
				+ "Speed         |	       10              |       12          |   	10		");
		charSelectText.setOpaque(false);
		Object[] characters = {Fighters.Cowboy, Fighters.Mouse, Fighters.Scientist};
		int charSelected = JOptionPane.showOptionDialog(null, charSelectText, "Character Selection", 
				JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, null, characters, null);
		Fighters selected = (Fighters) characters[charSelected];
		main = new Fighter(window.getWidth()/2,window.getHeight()-groundLevel-selected.getHeight(),selected);

		window.setVisible(true);
		tStart = System.currentTimeMillis();

		// Creating Debris
		for (int i = 0; i < numDebrises; i++) {
			debrises.add(new Debris(rnd.nextInt(window.getWidth()), -75, 50, 50, -2 + rnd.nextInt(4), 1 + rnd.nextInt(4)));
		}


		// Mouse Clicked
		this.addMouseListener(new MouseListener() {

			@Override
			public void mousePressed(MouseEvent e) {
				// Left Mouse Click = Shrink and Right Mouse Click = Grow for Debris and Fighter
				for ( Debris d : debrises ) {
					if ( d.contains(e.getPoint()) ) {
						if (SwingUtilities.isLeftMouseButton(e))
							d.changeSize(main, false);
						if (SwingUtilities.isRightMouseButton(e))
							d.changeSize(main, true);
					}
				}
				if ( main.contains(e.getPoint())) {
					if (SwingUtilities.isLeftMouseButton(e))
						main.changeSize(main, false);
					if (SwingUtilities.isRightMouseButton(e))
						main.changeSize(main, true);
					main.y = (int) (window.getHeight() - groundLevel - main.getHeight());
				}
			}

			@Override
			public void mouseReleased(MouseEvent e) { }
			@Override
			public void mouseExited(MouseEvent e) {	}
			@Override
			public void mouseEntered(MouseEvent e) { }
			@Override
			public void mouseClicked(MouseEvent e) { }
		});

		window.addKeyListener(new KeyListener() {
			@Override
			public void keyTyped(KeyEvent e) { }
			@Override
			public void keyReleased(KeyEvent e) {
				holdRight = false;
				holdLeft = false;
			}

			@Override
			public void keyPressed(KeyEvent e) {
				// A moves left, D moves right, and W shoots bullets
				// The Fighter is flipped to face the direction it's moving
				char c = e.getKeyChar();
				if (c == 'a') {
					holdLeft = true;
					main.move(false);
					main.setFlip(true);
				}
				if (c == 'd') {
					holdRight = true;
					main.move(true);
					main.setFlip(false);
				}
				if( c == 'w' )
					main.shoot(bullets, maxBullets);
			}
		});

		tmr = new Timer(30, new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				int currentTime = (int) ((System.currentTimeMillis() - tStart)/1000);
				// Key held Fighter movement
				if (holdLeft)
					main.move(false);
				if (holdRight)
					main.move(true);
				// Remove debris that is off the screen
				Iterator<Debris> iter = debrises.iterator();
				while (iter.hasNext()) {
					Debris d = iter.next();
					if ( !d.move(debrises, main) )
						iter.remove();
				}

				// Remove bullets that are off screen
				Iterator<Bullet> iterBullet = bullets.iterator();
				while (iterBullet.hasNext()) {
					Bullet b = iterBullet.next();
					if ( !b.move() )
						iterBullet.remove();
				}

				// Remove debris hit by bullets
				iterBullet = bullets.iterator();
				while ( iterBullet.hasNext() ) {
					Bullet b = iterBullet.next();
					iter = debrises.iterator();
					while (iter.hasNext()) {
						Debris d = iter.next();
						if ( d.intersects(b) ) {
							exploded.add(d);
							explodedFrame.add(1);
							d.loadExplode();
							iter.remove();
							iterBullet.remove();
							break;
						}
					}
				}

				// Add New Debris to fall from the sky
				if ( debrises.size() < numDebrises + currentTime/10 ) {
					for ( int i = debrises.size(); i < numDebrises + currentTime/10; i++) {
						Debris d  = new Debris(rnd.nextInt(window.getWidth()), -75, 50, 50, -2 + rnd.nextInt(4), 1 + rnd.nextInt(4));
						debrises.add(d);
						// Every 100 seconds, increase the speed of debris, but only do this a max of 6 times
						// otherwise it would be pratically impossible
						for (int j = 0; j < (currentTime/100 > 6 ? 6:currentTime/100) ; j++)
							d.setySpeed(d.getySpeed()*1.25);						
					}
				}

				// Check to see if the debris hit the fighter
				for ( Debris d : debrises) {
					if (d.intersects(main)) {					
						tmr.stop();
						JOptionPane.showMessageDialog(null, "Game Over\n" + "Your Score: " + currentTime);
						binaryHighScore(currentTime);
						return;
					}
				}

				repaint();
			}
		});
		tmr.start();
	}

	@Override
	protected void paintComponent(Graphics g) {
		super.paintComponent(g);
		// Draw Ground
		BufferedImage buffImg = new BufferedImage(700, 100, BufferedImage.TYPE_INT_ARGB);
		Image img = null;
		try {
			buffImg = ImageIO.read(new File("Ground_1.png"));
		} catch (IOException e) {
			System.out.println("ERROR");
			e.printStackTrace();
		}
		Graphics2D g2d = (Graphics2D) (g);
		g2d.drawImage(buffImg, 0, window.getWidth()-groundLevel, 700, 100, null);

		// Draw Main Fighter
		if (main != null)
			main.draw(g);
		// Draw Debris
		for ( Debris d : debrises )
			d.draw(g);
		// Draw Bullets
		for ( Bullet b : bullets )
			b.draw(g);
		// Draw Explosions
		Iterator<Debris> iterDebris = exploded.iterator();
		while (iterDebris.hasNext()) {
			Debris d = iterDebris.next();
			int frame = explodedFrame.get(exploded.indexOf(d));
			// Remove animations that are complete
			if (frame > 15) {
				explodedFrame.remove(exploded.indexOf(d));
				iterDebris.remove();
			} else {
				d.drawExplode(g, frame);
				explodedFrame.set(exploded.indexOf(d), ++frame);
			}
		}
		// Draw Time
		g.setFont(new Font("Arial", Font.PLAIN, 20));
		long currentTime = (System.currentTimeMillis() - tStart)/1000;
		g.drawString("" + currentTime, 640, 650);
	}

	// Read high scores and writes if your score is in the top 5
	// This method takes more lines of code than the one we wrote in class, but is much more efficient
	public static void binaryHighScore(int score) {
		RandomAccessFile raf = null;
		String name;
		boolean replaced = false;
		boolean added = false;
		String[] top5Names = new String[5];
		int[] top5Scores = new int[5];
		JFrame highScoreWindow = new JFrame("Top 5 High Scores");
		String output = " ***High Scores***\nName	Score\n";
		try {
			raf = new RandomAccessFile("hs5.bin", "rw");
			for (int i = 0; i < 5; i++) {
				added = false;
				if ( replaced && raf.getFilePointer() < raf.length() && i+1 < 5) {
					added = true;
					top5Names[i+1] = raf.readUTF();
					top5Scores[i+1] = raf.readInt();
				} else if(!replaced && raf.getFilePointer() < raf.length()) {
					added = true;
					top5Names[i] = raf.readUTF();
					top5Scores[i] = raf.readInt();
				} 
				
				if ( !replaced && score > top5Scores[i] ) {
					replaced= true;
					top5Names[i+1] = top5Names[i];
					top5Scores[i+1] = top5Scores[i];
					top5Names[i] = JOptionPane.showInputDialog(null, "New Top 5 High Score!\nEnter 3 Character Name:", "---").substring(0,3);
					top5Scores[i] = score;
				}
				else if ( !replaced && raf.getFilePointer() == raf.length() ) {
					replaced = true;
					if ( !added ) {
						top5Names[i] = JOptionPane.showInputDialog(null, "New Top 5 High Score!\nEnter 3 Character Name:", "---").substring(0,3);
						top5Scores[i] = score;
					} else {
						top5Names[i+1] = JOptionPane.showInputDialog(null, "New Top 5 High Score!\nEnter 3 Character Name:", "---").substring(0,3);
						top5Scores[i+1] = score;
					}
				}
				if ( top5Names[i] != null ) {
					if ( added )
						raf.seek(raf.getFilePointer()-9);
					output += "" + top5Names[i] + "	" + top5Scores[i] + "\n";
					raf.writeUTF(top5Names[i]);
					raf.writeInt(top5Scores[i]);
				}
				
			}
			JTextArea highScores = new JTextArea(output);
			highScores.setFont(new Font("Bank Gothic Light BT", Font.PLAIN, 16));
			highScores.setOpaque(false);
			JOptionPane.showMessageDialog(highScoreWindow, highScores);


		} catch (Exception e) {
			System.out.println(e.getMessage());
		} finally {
			try {	raf.close();	} catch (Exception e) {}
		}
	}
	public static void main(String[] args) {
		new Tester();
	}

}