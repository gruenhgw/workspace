public enum Fighters {
	Scientist (500, 500, 21, 49, 4, "Scientist_Pixel.png", "Scientist_Pixel_Flip.png"),
	Cowboy (600, 400, 25, 50, 4, "Cowboy_Pixel.png", "Cowboy_Pixel_Flip.png"),
	Mouse (500, 400, 50, 25, 8, "Mouse_Pixel.png", "Mouse_Pixel_Flip.png");
	//========================================================================================================Properties
	private int maxMassBar, maxNRGBar, width, height, xSpeed;
	private String fileName, fileNameFlip;
	//======================================================================================================Constructors
	private Fighters(int maxMassBar, int maxNRGBar, int width, int height, int xSpeed, String fileName, String fileNameFlip) {
		setMaxMassBar(maxMassBar);
		setMaxNRGBar(maxNRGBar);
		setWidth(width);
		setHeight(height);
		setxSpeed(xSpeed);
		setFileName(fileName);
		setFileNameFlip(fileNameFlip);
	}
	//===================================================================================================Getters/Setters
	public int getMaxMassBar() 							{	return maxMassBar;					}
	public void setMaxMassBar(int maxMassBar) 			{	this.maxMassBar = maxMassBar;		}
	public int getMaxNRGBar() 							{	return maxNRGBar;					}
	public void setMaxNRGBar(int maxNRGBar) 			{	this.maxNRGBar = maxNRGBar;			}
	public int getWidth() 								{	return width;						}
	public void setWidth(int width) 					{	this.width = width;					}
	public int getHeight() 								{	return height;						}
	public void setHeight(int height) 					{	this.height = height;				}
	public String getFileName() 						{	return fileName;					}
	public void setFileName(String fileName) 			{	this.fileName = fileName;			}
	public String getFileNameFlip() 					{	return fileNameFlip;				}
	public void setFileNameFlip(String fileNameFlip) 	{	this.fileNameFlip = fileNameFlip;	}
	public int getxSpeed() 								{	return xSpeed;						}
	public void setxSpeed(int xSpeed) 					{	this.xSpeed = xSpeed;				}
}