package io.github.henneberger;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.Value;

public class Day12a {
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
    HashSet<Integer> objects = new HashSet<>();
    for (int i = 0; i < in.size(); i++) {
      R r = l(i, objects);
      if (r.p != 0 && r.a != 0) {
        System.out.println(in.get(i) + ":" + r.a + " *" + r.p);
        total += r.a * r.p;
      }
    }
    System.out.println(total);
  }

  private static R l(int i, HashSet<Integer> seen) {
    if (seen.contains(i)) {
      return new R(0,0);
    }
    seen.add(i);
    Character c = in.get(i);

    //Walk
    int a = 1;
    int t_p = 0;

    if(!seen.contains(i+1) && (i + 1) % len != 0 && in.get(i+1) == c) {
      R r = l(i+1, seen);
      a+=r.a;
      t_p+=r.p;
    }
    if(!seen.contains(i-1) && i % len != 0 && in.get(i-1) == c) {
      R r = l(i-1, seen);
      a+=r.a;
      t_p+=r.p;
    }
    if(!seen.contains(i-len) && i - len >= 0 && in.get(i-len) == c) {
      R r = l(i-len, seen);
      a+=r.a;
      t_p+=r.p;
    }
    if(!seen.contains(i+len) && i + len < in.size() && in.get(i+len) == c) {
      R r = l(i+len, seen);
      a+=r.a;
      t_p+=r.p;
    }

    if((i + 1) % len == 0 || in.get(i+1) != c) {
      t_p++;
    }
    if(i % len == 0 || in.get(i-1) != c) {
      t_p++;
    }
    if(i - len < 0 || in.get(i-len) != c) {
      t_p++;
    }
    if(i + len >= in.size() || in.get(i+len) != c) {
      t_p++;
    }

    return new R(a, t_p);
  }

  @Value
  static class R {
    int a;
    int p;
  }
}
