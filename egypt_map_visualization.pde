import javax.swing.JOptionPane;
import java.util.ArrayList;

PImage map;
String[] rows;
ArrayList<Marker> markers = new ArrayList<Marker>();
int minPopulation = Integer.MAX_VALUE;
int maxPopulation = Integer.MIN_VALUE;
float originalImageWidth = 430.0f; // Store original image width
float originalImageHeight = 413.0f; // Store original image height

void setup() {
  size(891, 856); // Adjust this to your desired image size
  map = loadImage("egypt.png"); // Load the map image
  rows = loadStrings("data.tsv"); // Load TSV file

  // Calculate scaling factors based on original and current image sizes
  float xScalingFactor = width / originalImageWidth;
  float yScalingFactor = height / originalImageHeight;

  for (int i = 0; i < rows.length; i++) {
    String[] columns = split(rows[i], '\t');
    String governorate = columns[0];
    float x = float(columns[1]); // Assuming these are pixel coordinates
    float y = float(columns[2]); // Assuming these are pixel coordinates
    String populationString = columns[3].replace(",", "");
    int population = 0; // Default value
    if (!populationString.isEmpty()) { // Check if the string is not empty
      population = Integer.parseInt(populationString);
      minPopulation = min(minPopulation, population);
      maxPopulation = max(maxPopulation, population);
    }

    // Apply scaling factors to coordinates before creating Marker object
    float scaledX = x * xScalingFactor;
    float scaledY = y * yScalingFactor;

    Marker marker = new Marker(scaledX, scaledY, governorate, population);
    markers.add(marker);
  }

  map.resize(width, height); // Resize the image to the size of the window
}

void draw() {
  background(map);
  for (Marker marker : markers) {
    marker.display();
    if (marker.isInside(mouseX, mouseY)) {
      String message = "Governorate: " + marker.governorate + ", Population: " + marker.population;
      fill(0); // Set the text color to black
      textSize(22); // Set font size to 20

      // Calculate text width to center it horizontally
      float textWidth = textWidth(message);
      float textX = (width - textWidth) / 2; // Calculate x-position for centering

      // Calculate y-position with padding from the bottom
      float textY = height - 28; 

      text(message, textX, textY);
    }
  }
}

void mouseClicked() {
  for (Marker marker : markers) {
    if (marker.isInside(mouseX, mouseY)) {
      String message = "Governorate: " + marker.governorate + ", Population: " + marker.population;
      JOptionPane.showMessageDialog(null, message);
    }
  }
}

int minSize = 5; // Minimum size of a dot
int maxSize = 25; // Maximum size of a dot

class Marker {
  float x, y;
  String governorate;
  int population;

  Marker(float x, float y, String governorate, int population) {
    this.x = x;
    this.y = y;
    this.governorate = governorate;
    this.population = population;
  }

  void display() {
    // Normalize population value between 0 and 1
    float normalizedPopulation = (population - minPopulation) / (float) (maxPopulation - minPopulation);

    // Define color based on normalized population
    color color_range = getColorForPopulation(normalizedPopulation);

    fill(color_range);
    float size = map(population, minPopulation, maxPopulation, minSize, maxSize); // Calculate the size of the dot based on population
    ellipse(x, y, size, size); // Use the calculated size to draw the dot
  }

  // Function to define color based on normalized population
  color getColorForPopulation(float normalizedPopulation) {
    // Choose a color scheme (replace with your desired scheme)
    color color_range;
    if (normalizedPopulation <= 0.5f) {
      // Green to yellow gradient for lower population (adjust colors as needed)
      color_range = lerpColor(color(0, 128, 0), color(255, 255, 0), normalizedPopulation * 2);
    } else {
      // Yellow to red gradient for higher population
      color_range = lerpColor(color(255, 255, 0), color(255, 0, 0), (normalizedPopulation - 0.5f) * 2);
    }
    return color_range;
  }

  boolean isInside(float mx, float my) {
    float size = map(population, minPopulation, maxPopulation, minSize, maxSize); // Calculate the size of the dot based on population
    return dist(mx, my, x, y) < size/2; // Use the calculated size to check if the mouse is inside the dot
  }
}
