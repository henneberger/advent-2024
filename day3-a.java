
/**-- Sadly, REGEXP_EXTRACT_ALL is only in main, not released, so there is no path.

select REGEXP_EXTRACT_ALL(x, 'mul\((\d{1,3}),(\d{1,3})\)')
from (VALUES('xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))')) as t(x);
...*/

package io.henneberger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Day3Part1 {

  static Pattern p = Pattern.compile("mul\\((\\d{1,3}),(\\d{1,3})\\)");

  public static void main(String[] args) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
    int safeCount = 0;
    String line;
    while ((line = reader.readLine()) != null && !line.isEmpty()) {
      String t = line.trim();
      safeCount += parse(t);
    }

    System.out.println(safeCount);
  }

  private static int parse(String t) {
    Matcher matcher = p.matcher(t);
    int sum = 0;
    while (matcher.find()) {
      int x = Integer.parseInt(matcher.group(1));
      int y = Integer.parseInt(matcher.group(2));
      sum += (x * y);
    }
    return sum;
  }
}


