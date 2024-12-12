package io.github.henneberger;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.stream.Collectors;

public class Day12b {
  static String string ="RRRRIICCFF\n"
      + "RRRRIICCCF\n"
      + "VVRRRCCFFF\n"
      + "VVRCCCJFFF\n"
      + "VVVVCJJCFE\n"
      + "VVIVCCJJEE\n"
      + "VVIIICJJEE\n"
      + "MIIIIIJJEE\n"
      + "MIIISIJEEE\n"
      + "MMMISSJEEE";

  static int len = string.split("\n")[0].length();
  static List<Character> in = Arrays.stream(string.replaceAll("\n", "").split(""))
      .map(i->i.charAt(0))
      .collect(Collectors.toList());

  public static void main(String[] args) {
    long total = 0;
    HashSet<Integer> seen = new HashSet<>();
    for (int i = 0; i < in.size(); i++) {
      if (seen.contains(i)) continue;
      HashSet<Integer> region = new HashSet<>();
      getRegion(i, region);
      seen.addAll(region);

      int calc = calc(region);
      total += region.size() * calc;

    }
    System.out.println(total);
  }

  //Count corners
  private static int calc(HashSet<Integer> region) {
    int corners = 0;
    for (Integer r : region) {
      boolean hasLeft = r % len != 0 && region.contains(r - 1);
      boolean hasRight = (r + 1) % len != 0 && region.contains(r + 1);
      boolean hasTop = r - len >= 0 && region.contains(r - len);
      boolean hasBottom = r + len < in.size() && region.contains(r + len);
      //exterior
      if (!hasTop && !hasLeft) corners++;
      if (!hasTop && !hasRight) corners++;
      if (!hasBottom && !hasLeft) corners++;
      if (!hasBottom && !hasRight) corners++;
      //interior
      if (hasTop && hasLeft && !region.contains(r-len-1)) corners++;
      if (hasTop && hasRight && !region.contains(r-len+1)) corners++;
      if (hasBottom && hasRight && !region.contains(r+len+1)) corners++;
      if (hasBottom && hasLeft && !region.contains(r+len-1)) corners++;
    }
    return corners;
  }

  private static void getRegion(int i, HashSet<Integer> seen) {
    if (seen.contains(i)) {
      return;
    }
    seen.add(i);
    Character c = in.get(i);

    if(!seen.contains(i+1) && (i + 1) % len != 0 && in.get(i+1) == c) {
      getRegion(i+1, seen);
    }
    if(!seen.contains(i-1) && i % len != 0 && in.get(i-1) == c) {
      getRegion(i-1, seen);
    }
    if(!seen.contains(i-len) && i - len >= 0 && in.get(i-len) == c) {
      getRegion(i-len, seen);
    }
    if(!seen.contains(i+len) && i + len < in.size() && in.get(i+len) == c) {
      getRegion(i+len, seen);
    }
  }
}
