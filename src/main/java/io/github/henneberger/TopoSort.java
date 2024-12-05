package io.github.henneberger;

import com.google.common.graph.GraphBuilder;
import com.google.common.graph.ImmutableGraph;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.apache.flink.table.functions.ScalarFunction;

public class TopoSort extends ScalarFunction {

  public List<Integer> eval(List<List<Integer>> pairs) {
    ImmutableGraph.Builder<Integer> graphBuilder = GraphBuilder.directed().immutable();
    for (List<Integer> edge : pairs) {
      graphBuilder.putEdge(edge.get(0), edge.get(1));
    }
    List<Integer> integers = topologicalSort(graphBuilder.build());
    return integers;
  }

  public static List<Integer> topologicalSort(ImmutableGraph<Integer> g) {
    Map<Integer, Integer> d = new HashMap<>();
    for (Integer n : g.nodes()) {
      d.put(n, 0);
    }
    for (Integer n : g.nodes()) {
      for (Integer s : g.successors(n)) {
        d.put(s, d.get(s) + 1);
      }
    }

    System.out.println(d);
    return d.entrySet().stream()
        .sorted(Map.Entry.comparingByValue())
        .map(Map.Entry::getKey)
        .collect(Collectors.toList());
  }
}
