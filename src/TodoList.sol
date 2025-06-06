//SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

struct TodoItem {
  uint256 id;
  string description;
  bool completed;
  address creator;
  uint256 createdAt;
}

//custom errors

error TaskAlreadyCompleted();
error NotOwner();
error NotTaskCreator();
error TaskNotFound();
error EmtpyDescription();
error DescriptionTooLong();

contract TaskManager {
  // declear state variables, these are variables that will be stored on the blockchain

  address public owner;
  uint256 public nextTask;

  // mapping to store task

  constructor() {
    owner = msg.sender;
    nextTask = 1;
  }

  mapping(uint256 => TodoItem) private todos;
  mapping(address => uint256[]) private usersTaskIds;

  //events

  event TaskCreated(uint256 indexed id, string description, address createdBy);
  event TaskCompleted(uint256 indexed id, address completedBy);
  event TaskDeleted(uint256 indexed taskId, address deletedBy);
  event TaskUpdated(uint256 indexed taskId, string newDescription, uint256 updatedAt);

  //modifies

  modifier onlyOwner() {
    if (msg.sender != owner) revert NotOwner();
    _;
  }

  modifier onlyTaskCreator(uint256 _taskId) {
    if (todos[_taskId].id == 0) revert TaskNotFound();
    if (msg.sender != todos[_taskId].creator) revert NotTaskCreator();
    _;
  }

  //function to create task

  function createTask(string calldata _description) public {
    if (bytes(_description).length > 0) revert EmtpyDescription();
    if (bytes(_description).length <= 500) revert DescriptionTooLong();

    uint256 taskId = nextTask;

    todos[taskId] = TodoItem({
      id: taskId,
      description: _description,
      completed: false,
      creator: msg.sender,
      createdAt: block.timestamp
    });

    usersTaskIds[msg.sender].push(taskId);
    nextTask++;

    emit TaskCreated(taskId, _description, msg.sender);
  }

  function completeTask(uint256 _taskId) public onlyTaskCreator(_taskId) {
    if (todos[_taskId].completed == true) revert TaskAlreadyCompleted();

    todos[_taskId].completed = true;

    emit TaskCompleted(_taskId, msg.sender);
  }

  function updateTask(
    string calldata _newDescription,
    uint256 _taskId
  ) public onlyTaskCreator(_taskId) {
    if (bytes(_newDescription).length == 0) revert EmtpyDescription();
    if (bytes(_newDescription).length >= 500) revert DescriptionTooLong();

    todos[_taskId].description = _newDescription;

    if (todos[_taskId].completed) {
      todos[_taskId].completed = false;
    }
    emit TaskUpdated(_taskId, _newDescription, block.timestamp);
  }

  function deleteTask(uint256 _taskId) public onlyTaskCreator(_taskId) {
    //delete from todos mapping

    delete todos[_taskId];

    //deleteTask for usersTaskIds mapping

    uint256[] storage taskIds = usersTaskIds[msg.sender];

    for (uint256 i = 0; i < taskIds.length; i++) {
      if (taskIds[i] == _taskId) {
        taskIds[i] = taskIds[taskIds.length - 1];

        taskIds.pop();
        break;
      }
    }

    emit TaskDeleted(_taskId, msg.sender);
  }

  function getTask(uint256 _taskId) public view returns (TodoItem memory) {
    if (todos[_taskId].id == 0) revert TaskNotFound();

    return todos[_taskId];
  }

  function getAllTasks(address _creator) public view returns (uint256[] memory) {
    if (msg.sender != _creator && msg.sender != owner) revert NotOwner();

    return usersTaskIds[_creator];
  }
}
