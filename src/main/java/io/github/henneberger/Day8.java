package io.github.henneberger;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

public class Day8 {

  public static void main(String[] args) throws IOException {
    String s = Files.readString(
        Path.of("/Users/henneberger/advent-of-code/data/day8.txt"));
    int len = s.indexOf("\n");
    StringBuilder builder = new StringBuilder(s.replaceAll("\\\n", ""));

    //create map
    Map<Character, List<Integer>> map = new HashMap<>();
    for (int i = 0; i < builder.length(); i++) {
      Character c = builder.charAt(i);
      List<Integer> ints = map.computeIfAbsent(c, k -> new ArrayList<>());
      ints.add(i);
    }

    HashSet<Integer> set = new HashSet();

    for (Map.Entry<Character, List<Integer>> entry : map.entrySet()) {
      if(entry.getKey() == '#' || entry.getKey() == '.') continue;
      List<Integer> value = entry.getValue();

      for (int i = 0; i < value.size()/2+1; i++) {
        for (int j = i+1; j < value.size(); j++) {
          Integer i1 = value.get(i);
          Integer i2 = value.get(j);
          int diff = i2 - i1;

          if (i1 - diff >= 0 &&
              (i2% len  >= i1% len  ?
              i1 % len >= (i1 - diff) % len :
              i1 % len <= (i1 - diff) % len)
          ) {
            set.add(i1 - diff);
          }
          if (i2 + diff < builder.length() &&
              (i2% len  >= i1% len  ?
                  i2 % len <= (i2 + diff) % len :
                  i2 % len >= (i2 + diff) % len)) {
            set.add(i2 + diff);
          }
        }
      }
//      for (Integer z : set) {
//        System.out.printf("(%d, %d) %d\n", z/len, z % len, z);
//      }

      System.out.println(entry.getKey() + ": " + set.size());
    }

    System.out.println(set.size());
    //probably easier with one long
  }
}
