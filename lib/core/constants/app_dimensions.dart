// 70 /890 * height

const totalHeight = 890;
const totalWidth = 411;

// Calculate responsive horizontal padding
double horizontalPaddingFactor(double width) {
  return width / totalWidth;
}

// Calculate responsive vertical padding
double verticalPaddingFactor(double height) {
  return height / totalHeight;
}

// Calculate responsive border Container
double responsiveContainerSize(double baseSize, double width, double height) {
  double scaleFactor = (width / totalWidth + height / totalHeight) / 2;
  return baseSize * scaleFactor;
}

// Calculate responsive border fontsize
double responsiveFontSize(
    double baseSize, double width, double height, double textScaleFactor) {
  double scaleFactor = (width / 411 + height / 890) / 2;
  return baseSize * scaleFactor * textScaleFactor;
}

// Calculate responsive border radius
double responsiveBorderRadius(double baseRadius, double width, double height) {
  double scaleFactor = (width / totalWidth + height / totalHeight) / 2;
  return baseRadius * scaleFactor;
}

// Calculate responsive border width
double responsiveBorderWidth(double baseWidth, double width, double height) {
  double scaleFactor = (width / totalWidth + height / totalHeight) / 2;
  return baseWidth * scaleFactor;
}
