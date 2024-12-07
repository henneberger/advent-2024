package io.github.henneberger.day7;

import java.util.ArrayList;
import java.util.List;
import org.apache.flink.table.functions.TableFunction;

public class OperatorPermuteFunction extends TableFunction<String[]> {

  private static final long serialVersionUID = 1L;

  private static final String[] OPERATORS = {"||", "*", "+"};

  public void eval(int length) {
    if (length <= 0) {
      // Emit an empty sequence for non-positive lengths
      collect(new String[0]);
      return;
    }
    List<String[]> permutations = generatePermutations(length);
    for (String[] permutation : permutations) {
      collect(permutation);
    }
  }

  private List<String[]> generatePermutations(int length) {
    List<String[]> result = new ArrayList<>();
    backtrack(result, new String[length], 0);
    return result;
  }

  private void backtrack(List<String[]> result, String[] current, int position) {
    if (position == current.length) {
      result.add(current.clone());
      return;
    }
    for (String operator : OPERATORS) {
      current[position] = operator;
      backtrack(result, current, position + 1);
    }
  }
}
