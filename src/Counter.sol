// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
  uint256 public number;

  function setNumber(uint256 newNumber) public {
    number = newNumber;
  }

  function increment() public {
    number++;
  }

  // Can you write a function that:
  // 1. Takes a Student struct
  // 2. Calculates their average age
  // 3. Emits an event with the result

  struct Student {
    uint256 id;
    string name;
    uint256 age;
  }

  event StudentAverageAge(uint256 indexed id, string indexed name, uint256 totalAge);

  function calStudentsAverageAge(Student[] calldata students) public pure returns (uint256) {
    uint256 totalAge = 0;

    for (uint256 i = 0; i < students.length; i++) {
      totalAge += students[i].age;
    }

    uint256 averageAge = totalAge / students.length;

    return averageAge;
  }
}
