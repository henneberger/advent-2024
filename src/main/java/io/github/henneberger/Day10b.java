package io.github.henneberger;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class Day10b {
  static String string ="89010123\n"
      + "78121874\n"
      + "87430965\n"
      + "96549874\n"
      + "45678903\n"
      + "32019012\n"
      + "01329801\n"
      + "10456732\n";

  static List<Integer> a = Arrays.stream(string.replaceAll("\n", "").split(""))
      .map(i->{
        try {
          return Integer.parseInt(i);
        } catch (NumberFormatException e) {
          return -1;
        }
      })
      .collect(Collectors.toList());

  static int len = string.split("\n")[0].length();
  public static void main(String[] args) {
    int total = 0;
    for (int i = 0; i < a.size(); i++) {
      if (a.get(i) == 0) {
        List<Integer> seen = new ArrayList<>();
        descend(i, seen);
        total += set.size();
        set.clear();
      }
    }
    System.out.println(total);
  }

  static List<List<Integer>> set = new ArrayList<>();
  private static void descend(int i, List<Integer> path) {
    path.add(i);
    List<Integer> curPath = new ArrayList<>(path);
    if (a.get(i) == 9) {
      set.add(new ArrayList<>(path));
      return;
    }

    if (i - len >= 0 && a.get(i - len) == a.get(i) + 1) {
      descend(i-len, curPath);
    }
    if (i + len < a.size() && a.get(i+len) == a.get(i) + 1) {
      descend(i+len, curPath);
    }
    if (i % len != 0 && a.get(i-1) == a.get(i) + 1) {
      descend(i-1, curPath);
    }
    if ((i + 1) % len != 0 && a.get(i+1) == a.get(i) + 1) {
      descend(i+1, curPath);
    }
  }
}
