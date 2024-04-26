// Import necessary libraries
import javax.swing.JOptionPane; // For showing messages and getting user input
import java.util.ArrayList; // For storing and managing collections of data

// Declare global variables
PImage map; // Variable for storing the map image
String[] rows; // Array to store rows of data from TSV file
ArrayList<Marker> markers = new ArrayList<Marker>(); // List to store Marker objects
int minPopulation = Integer.MAX_VALUE; // Variable to store minimum population
int maxPopulation = Integer.MIN_VALUE; // Variable to store maximum population
float originalImageWidth = 430.0f; // Store original image width
float originalImageHeight = 413.0f; // Store original image height

// Setup function - runs once at the beginning
void setup() {
  // Set the size of the window
  size(891, 856);
  
  // Load the map image
  map = loadImage("egypt.png");
  
  // Load data from TSV file
  rows = loadStrings("data.tsv");

  // Calculate scaling factors based on original and current image sizes
  float xScalingFactor = width / originalImageWidth;
  float yScalingFactor = height / originalImageHeight;

  // Process each row of data
  for (int i = 0; i < rows.length; i++) {
    String[] columns = split(rows[i], '\t');
    String governorate = columns[0];
    float x = float(columns[1]); // Assuming these are pixel coordinates
    float y = float(columns[2]); // Assuming these are pixel coordinates
    String populationString = columns[3].replace(",", "");
    int population = 0; // Default value
    
    // Check if population string is not empty
    if (!populationString.isEmpty()) {
      population = Integer.parseInt(populationString);
      // Update minPopulation and maxPopulation
      minPopulation = min(minPopulation, population);
      maxPopulation = max(maxPopulation, population);
    }

    // Apply scaling factors to coordinates before creating Marker object
    float scaledX = x * xScalingFactor;
    float scaledY = y * yScalingFactor;

    // Create Marker object and add it to the markers list
    Marker marker = new Marker(scaledX, scaledY, governorate, population);
    markers.add(marker);
  }

  // Resize the map image to fit the window size
  map.resize(width, height);
}

// Draw function - runs continuously
void draw() {
  // Display the map background
  background(map);
  
  // Display markers
  for (Marker marker : markers) {
    marker.display();
    // Show details when mouse is over a marker
    if (marker.isInside(mouseX, mouseY)) {
      showDetails(marker);
    }
  }
}

// Function to show details of a marker
void showDetails(Marker marker) {
  String message = "Governorate: " + marker.governorate + ", Population: " + marker.population;
  fill(0); // Set the text color to black
  textSize(22); // Set font size
  // Center text horizontally
  float textWidth = textWidth(message);
  float textX = (width - textWidth) / 2;
  // Position text near the bottom of the window
  float textY = height - 28;
  text(message, textX, textY);
}

// Function to handle mouse click events
void mouseClicked() {
  // Show details of clicked marker in a dialog box
  for (Marker marker : markers) {
    if (marker.isInside(mouseX, mouseY)) {
      String message = "Governorate: " + marker.governorate + ", Population: " + marker.population;
      JOptionPane.showMessageDialog(null, message);
    }
  }
}

// Marker class
class Marker {
  float x, y; // Position of the marker
  String governorate; // Name of the governorate
  int population; // Population of the governorate

  // Constructor
  Marker(float x, float y, String governorate, int population) {
    this.x = x;
    this.y = y;
    this.governorate = governorate;
    this.population = population;
  }

  // Display the marker
  void display() {
    // Normalize population value between 0 and 1
    float normalizedPopulation = (population - minPopulation) / (float) (maxPopulation - minPopulation);
    // Define color based on normalized population
    color colorRange = getColorForPopulation(normalizedPopulation);
    fill(colorRange);
    // Calculate size of the marker based on population
    float size = map(population, minPopulation, maxPopulation, minSize, maxSize);
    // Draw the marker
    ellipse(x, y, size, size);
  }

  // Define color based on normalized population
  color getColorForPopulation(float normalizedPopulation) {
    color colorRange;
    // Green to yellow gradient for lower population, yellow to red for higher population
    if (normalizedPopulation <= 0.5f) {
      colorRange = lerpColor(color(0, 128, 0), color(255, 255, 0), normalizedPopulation * 2);
    } else {
      colorRange = lerpColor(color(255, 255, 0), color(255, 0, 0), (normalizedPopulation - 0.5f) * 2);
    }
    return colorRange;
  }

  // Check if the given point is inside the marker
  boolean isInside(float mx, float my) {
    // Calculate size of the marker
    float size = map(population, minPopulation, maxPopulation, minSize, maxSize);
    // Check if the point is inside the marker
    return dist(mx, my, x, y) < size / 2;
  }
}

// Define minimum and maximum marker sizes
int minSize = 5;
int maxSize = 25;
