import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  
  static final light= ThemeData(
    primaryColor: Colors.red,
    brightness: Brightness.light
  );

  static final dark= ThemeData(
    primaryColor: Colors.yellow,
    brightness: Brightness.light
  );
}

TextStyle get subHeadingStyle{
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold
    )
  );
}

TextStyle get HeadingStyle{
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold
    )
  );
}

TextStyle get titleStyle{
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold
    )
  );
}

TextStyle get subtitleStyle{
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey
    )
  );
}