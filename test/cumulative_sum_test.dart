import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   List<int> myList = [4, 6, 1, 3, 1, 5];
//
//   List<int> expectedResult = [20, 16, 10, 9, 6, 5];
//
//   test('cumulativeSum from back', () {
//     expect(cumulativeSumFromBack(myList), equals(expectedResult));
//   });
// }
//
// List<int> cumulativeSumFromBack(List<int> list) {
//   List<int> result = [];
//
//   for (int i = 0; i < list.length; i++) {
//     int temp =
//         (result.isNotEmpty ? result[i - 1] : 0) + list[(list.length - 1) - i];
//     result.add(temp);
//   }
//
//   return result.reversed.toList();
// }

//import 'package:flutter_test/flutter_test.dart';

void main() {
  List<int> myList = [4, 6, 1, 3, 1, 5];

  List<int> expectedResult = [20, 16, 10, 9, 6, 5];

  test('cumulativeSum from back', () {
    expect(cumulativeSumFromBack(myList), equals(expectedResult));
  });
}

List<int> cumulativeSumFromBack(List<int> list) {
  List<int> result = List.filled(list.length, 0);
  int sum = 0;

  for (int i = list.length - 1; i >= 0; i--) {
    sum += list[i];
    result[i] = sum;
  }

  return result;
}
