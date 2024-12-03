package com.datasqrl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Day3Part2 {

  static Pattern p = Pattern.compile("mul\\((\\d{1,3}),(\\d{1,3})\\)|don't\\(\\)|do\\(\\)");

  public static void main(String[] args) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
    long safeCount = 0;
    String line;
    while ((line = reader.readLine()) != null && !line.isEmpty()) {
      String t = line.trim();
      for (String x : t.split("\n")) {
        safeCount += parse(t);
      }
    }

    System.out.println(safeCount);
  }
  static boolean donotSkip = true;

  private static long parse(String t) {
    Matcher matcher = p.matcher(t);
    int sum = 0;
    while (matcher.find()) {
      String group = matcher.group();
      switch (group.substring(0, Math.min(group.length(), 3))) {
        case "mul":
          if (donotSkip) {
            int x = Integer.parseInt(matcher.group(1));
            int y = Integer.parseInt(matcher.group(2));
            sum += (x * y);
          } else {
          }
          break;

        case "don":
          donotSkip = false;
          break;
        default:
          donotSkip = true;
          break;
      }


    }
    return sum;
  }
}
