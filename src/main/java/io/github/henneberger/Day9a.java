package io.github.henneberger;

import java.util.ArrayDeque;
import java.util.Arrays;
import java.util.Deque;
import java.util.List;
import java.util.stream.Collectors;

public class Day9a {

  static List<Integer> a = Arrays.stream("2333133121414131402".split("")).map(Integer::parseInt)
      .collect(Collectors.toList());

  public static void main(String[] args) {
    Deque<Long> elements = new ArrayDeque<>();
    for (int i = 0; i < a.size(); i += 1) {
      for (int j = 0; j < a.get(i); j++) {
        if (i % 2 == 0) {
          elements.add((long) i / 2);
        } else {
          elements.add(-1L);
        }
      }
    }

    long idx = 0;
    long total = 0;
    while (!elements.isEmpty()) {
      Long i = elements.pop();
      if (i == -1) {
        Long i1;
        while((i1 = elements.pollLast() ) == -1) {}
        total += (idx++) * i1;
      } else {
        total += (idx++) * i;
      }
    }

    System.out.println(total);
  }


}
