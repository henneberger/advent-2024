package io.github.henneberger;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Deque;
import java.util.List;
import java.util.stream.Collectors;

public class Day9b {

  static List<Integer> a = Arrays.stream("2333133121414131402".split("")).map(Integer::parseInt)
      .collect(Collectors.toList());

  public static void main(String[] args) {
    List<Long> elements = new ArrayList<>();
    for (int i = 0; i < a.size(); i += 1) {
      for (int j = 0; j < a.get(i); j++) {
        if (i % 2 == 0) {
          elements.add((long) i / 2);
        } else {
          elements.add(-1L);
        }
      }
    }

    for (int i = elements.size() - 1; i >= 0; i--) {
      if (elements.get(i) == -1) continue;
      int end = i;
      int count = 0;//
      while (i-count >= 0) {
        if (elements.get(i - count).equals(elements.get(i))
            && elements.get(i-count) != -1) {
          count++;
        } else {
          break;
        }
      }
      i-=count-1;

      //try to place the element
      for (int j = 0; j < elements.size() && i > j; j++) {
        Long ele = elements.get(j);
        if (ele == -1) {
          int count2 = 0;
          while (j+count2 < elements.size()) {
            if (elements.get(j+count2) == -1) {
              count2++;
            } else {
              break;
            }
          }

          if (count2 >= count) {
            for (int k = 0; k < count; k++) {
              elements.set(j + k, elements.get(end-k));
              elements.set(end-k, -1L);
            }
            break;
          }
        }
      }
    }

    long total = 0;
    for (int i = 0; i < elements.size(); i++) {
      if (elements.get(i) != -1) {
       total += elements.get(i) * i;
      }
    }
    System.out.println(total);
  }


}
