import 'node_model.dart';

class LevelMapData {
  static List<MapNode> levelNodes() {
    return [
      MapNode(x: 0.25, y: 0.10, unlocked: true,  asset: "assets/icons/open-book.svg"),
      MapNode(x: 0.60, y: 0.20, unlocked: true,  asset: "assets/icons/open-book.svg"),
      MapNode(x: 0.40, y: 0.32, unlocked: false, asset: "assets/icons/book.svg"),
      MapNode(x: 0.70, y: 0.42, unlocked: false, asset: "assets/icons/book.svg"),
      MapNode(x: 0.30, y: 0.54, unlocked: false, asset: "assets/icons/book.svg"),
      MapNode(x: 0.65, y: 0.64, unlocked: false, asset: "assets/icons/book.svg"),
      MapNode(x: 0.30, y: 0.74, unlocked: false, asset: "assets/icons/book.svg"),
      MapNode(x: 0.60, y: 0.82, unlocked: false, asset: "assets/icons/book.svg"),
      MapNode(x: 0.32, y: 0.90, unlocked: false, asset: "assets/icons/book.svg"),
      MapNode(x: 0.60, y: 1.00, unlocked: false, asset: "assets/icons/book.svg"),
    ];
  }
}

