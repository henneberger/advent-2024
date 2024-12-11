package io.github.henneberger;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class Day11a {
  static String string ="28591 78 0 3159881 4254 524155 598 1";

  static List<Long> a = Arrays.stream(string.split(" ")).map(Long::parseLong)
      .collect(Collectors.toList());

  public static void main(String[] args) {

    for (int j = 0; j < 25; j++) {
      System.out.println(j);
      for (int i = 0; i < a.size(); i++) {
        long val = a.get(i);
        String str = String.valueOf(val);

        if (val == 0) {
          a.set(i, 1L);
        } else if (val == 1) {
          a.set(i, 2024L);
        } else if (str.length() % 2 == 0) {
          String x = str.substring(0, (str.length() / 2) );
          String y = str.substring(str.length() / 2);
          a.set(i, Long.parseLong(x));
          a.add(i+1, Long.parseLong(y));
          i++;
        } else {
          a.set(i, val * 2024);
        }
      }
      System.out.println(a.size());

    }

    System.out.println(a.size());
  }



}
