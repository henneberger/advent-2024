package io.github.henneberger;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

public class Day11b {
  static String string ="28591 78 0 3159881 4254 524155 598 1";

  static List<Long> a = Arrays.stream(string.split(" ")).map(Long::parseLong)
      .collect(Collectors.toList());

  public static void main(String[] args) {

    long total = 0;
    for (int i = 0; i < a.size(); i++) {
      total+= sum(a.get(i), 0);
    }
    System.out.println(total);

  }

  static class P {
    Long val;
    Integer level;

    public P(Long val, Integer level) {
      this.val = val;
      this.level = level;
    }

    @Override
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (o == null || getClass() != o.getClass()) {
        return false;
      }
      P p = (P) o;
      return Objects.equals(val, p.val) && Objects.equals(level, p.level);
    }

    @Override
    public int hashCode() {
      return Objects.hash(val, level);
    }
  }
  static Map<P, Long> memoize = new HashMap<>();
  private static long sum(Long val, int pos) {
    if (pos == 75) {
      return 1;
    }
    P p = new P(val, pos);
    if (memoize.containsKey(p)) {
      return memoize.get(p);
    }
    String str = String.valueOf(val);

    long total;
    if (val == 0) {
      total = sum(1L, pos + 1);
    } else if (val == 1) {
      total = sum(2024L, pos + 1);
    } else if (str.length() % 2 == 0) {
      String x = str.substring(0, (str.length() / 2) );
      String y = str.substring(str.length() / 2);
      total = sum(Long.parseLong(x), pos + 1) + sum(Long.parseLong(y), pos + 1);
    } else {
      total = sum(val*2024, pos+1);
    }
    memoize.put(p, total);
    return total;
  }
}
