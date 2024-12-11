package io.github.henneberger;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class Day10a {
  static String string ="89010123\n"
    + "78121874\n"
    + "87430965\n"
    + "96549874\n"
    + "45678903\n"
    + "32019012\n"
    + "01329801\n"
    + "10456732\n";

  static List<Integer> a = Arrays.stream(string.replaceAll("\n", "").split("")).map(Integer::parseInt)
      .collect(Collectors.toList());

  static int len = string.split("\n")[0].length();
  public static void main(String[] args) {
    //Strategy: start at highest point and create set of exit positions

    Map<Integer, Integer> count = new HashMap<>();
    for (int i = 0; i < a.size(); i++) {
      if (a.get(i) == 9) {
        Set<Integer> seen = new HashSet<>();
        Set<Integer> output = new HashSet<>();
        descend(i, output,seen);
        System.out.println(output.size());
        for (Integer j : output) {
          count.putIfAbsent(j, 0);
          count.put(j, count.get(j)+1);
        }
      }
    }

    int total = 0;
    for (Map.Entry<Integer, Integer> m : count.entrySet()) {
        System.out.println(m.getKey() + " : " + m.getValue());
        total += m.getValue();
    }
    System.out.println(total);
  }

  private static void descend(int i, Set<Integer> output, Set<Integer> seen) {
    if (seen.contains(i)) {
      return;
    } else {
      seen.add(i);
    }
    if (a.get(i) == 0) {
      output.add(i);
    }
    if (i - len >= 0 && a.get(i-len) - a.get(i) == -1) {
      descend(i-len, output, seen);
    }
    if (i + len < a.size() && a.get(i+len) - a.get(i) == -1) {
      descend(i+len, output, seen);
    }
    if (i % len > (i-1) % len && i - 1 > 0 && a.get(i-1) - a.get(i) == -1) {
      descend(i-1, output, seen);
    }
    if (i % len < (i+1) % len && i + 1 < a.size() && a.get(i+1) - a.get(i) == -1) {
      descend(i+1, output, seen);
    }

    //fall through if no path can be found
  }


}
