package io.github.henneberger;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;

public class Day7 {

  public static void main(String[] args) {
    Scanner in = new Scanner(System.in);
    String line;
    BigInteger total = BigInteger.ZERO;
    BigInteger total2 = BigInteger.ZERO;
    while (!(line = in.nextLine()).isEmpty()) {
      line = line.trim();
      String[] split = line.split(": ");
      BigInteger target = new BigInteger(split[0]);
      List<Long> nums = Arrays.stream(split[1].split(" ")).map(Long::parseLong)
          .collect(Collectors.toList());

      boolean valid = problem(target.longValue(), nums, 0, 0, false);

      if (valid) {
        total = total.add(target);
      }

      boolean valid2 = problem(target.longValue(), nums, 0, 0, true);

      if (valid2) {
        total2 = total2.add(target);
      }
    }
    System.out.println(total);
    System.out.println(total2);
  }

  private static boolean problem(long target, List<Long> nums, int idx,
      long sumSoFar, boolean supportPlus) {
    if (sumSoFar < 0) {
      return false;
    }
    if (idx == nums.size()) {
      return target == sumSoFar;
    }

    if (supportPlus) {
      boolean b;
      BigInteger val = new BigInteger((sumSoFar == 0 ? "" : sumSoFar) + "" + nums.get(idx));
      if (val.bitLength() <= 63 && (b = problem(target, nums, idx + 1, val.longValue(), supportPlus))) {
        return b;
      }
    }

    if (problem(target, nums, idx + 1, sumSoFar + nums.get(idx), supportPlus)) {
      return true;
    }

    if (idx == 0) { //if first value is a multiplication
      return problem(target, nums, idx + 2, nums.get(idx) * nums.get(idx+1), supportPlus);
    } else {
      return problem(target, nums, idx + 1, sumSoFar * nums.get(idx), supportPlus);
    }
  }
}
