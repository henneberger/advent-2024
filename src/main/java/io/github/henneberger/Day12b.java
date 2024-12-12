package io.github.henneberger;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.stream.Collectors;
import lombok.Value;

//!!!! NOT FINISHED
//!!!! WIP
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

      int calc = calc(region.stream().findFirst().get(), region);
      System.out.println(calc);
      System.out.println(in.get(i) + " : "+ calc +" * " + region.size());
    }
    System.out.println(total);
  }

  private static int calc(Integer start, HashSet<Integer> region) {
    //todo: build a set of edges and merge?

    return 0;
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
