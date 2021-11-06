
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  address public owner;

  int public parentId;

  int public parentCount;

  int public tripBlockSize;

  mapping(address => ParentInfo) parentTrips;

  mapping(address => bool) blacklistedParents;

  int constant MAXPARENTS = 5;

  int constant MAX_ADVANCETRIPS = 3;

 // bool carPoolBlockStarted;

 // bool prevBlockCompleted = false;


  enum State {Start, InProgress, End, Init}

  State globalCarpoolState;

  struct ParentInfo{
    string name;
    int totalTripsToDo;
    int tripsCompleted;
    int advanceTripsCompleted;
    int deleteAttempt;
    State tripState;
    address parentSwapFrom;
   // address parentSwapTo;
  }
  
  /* 
   * Events
   */

  event LogParentTrip(address parent);

  event LogAdvanceParentTrip(address parent);

  event LogAddParentToCarPool(string name);

  event LogDeleteParentFromCarpool(address parent);

 event LogAddParentToBlacklist(address parent);

 event LogParentTripInitlized(address parent);

 event LogStartCarpoolBlock();
 
 event LogEndCarpoolBlock();

 event LogWarningBlacklist(address parent);

  
  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner

  modifier isOwner (address _address) { 
     require (owner == _address); 
    _;
  }

  modifier checkParentCanBeAdded(){
    require (parentCount <= MAXPARENTS);
    _;
  }

  modifier isParentBlackListed(address parent){
    require (blacklistedParents[parent]);
    _;
  }

   modifier requiredTripsNotComplete(){
    require ( getTotalTrips (msg.sender) < parentTrips[msg.sender].totalTripsToDo);
    _;
  }

 modifier currentScheduleNotStarted(){
    require (tripBlockSize == 0);
    _;
  }

   modifier requiredTripsCompleted(){
    require (parentTrips[msg.sender].totalTripsToDo == parentTrips[msg.sender].tripsCompleted);
    _;
  }

  modifier currentScheduleRunning(){

    require(globalCarpoolState == State.Start);
    _;
  }

  constructor() public {
    owner = msg.sender;
    parentId = 1;

    // 1. Set the owner to the transaction sender
    
  }

    // 1. Check if the parent can be added at this time.
    //   - This is determined by whether the already added parents have completed their pickup schedules. 
    //   - Minimum 2 parents needed to start, so the first 2 parents will skip this check.
    // 2. Calculate the tripBlockSize For e.g if there are 4 parents already added, we want to allocate 2 weeks = 10 trips .
    // So the tripBlockSize=5, each parent needs to do 5 trips in 2 weeks to be equitable to the schedule
    // 3. Make sure the parent is NOT in the blacklist
    //    -  if they are in blacklist 
    //      - emit event 
    //      - return false
    // 4. If parent is added
    //    - increment parentCount
    //    - set the schduleCount in the mapping parentTrips
    //    - return true
    // 5. If the parent cant be added and are not blacklisted
    //   -  emit the event
    //   -  show when they can be added next
    //   - return false
  function addParentToCarpool(string memory _name) checkParentCanBeAdded() isParentBlackListed(msg.sender) currentScheduleNotStarted() public returns (int message) {
    
    parentTrips[msg.sender]=ParentInfo({
      name: _name,
      totalTripsToDo: -1,
      tripsCompleted: -1,
      advanceTripsCompleted: 0,
      deleteAttempt: 0,
      tripState: State.Init,
      parentSwapFrom: msg.sender,
      parentSwapTo: address(0)
    });
  
    parentId = parentId+1;
    parentCount = parentCount+1;
    emit LogAddParentToCarPool(_name);
    return parentId;
  }


  // 1. Check if the parent can be removed from carpool - If its in the middle of tripBlockSize, all parents are NOT done with their quota, 
  // check the allowBlacklist mapping.
  // 2. If all parents are done with their quota, 
  //    - remove them from mapping
  //    - emit event
  //    - decrement parentCount
  //    - return true
  //    - ignore allowBlacklist
  // 3. If all parents are not done , and allowBlacklist is false
  //   - dont remove them from mapping
  //   - show an error message asking them to wait 
  //   - dont decrement parentCount
  //   -  emit a message 
  //   - return false
  // 4. If all parents are not done , and allowBlacklist is true
  //   - show an message telling they will be removed and blacklisted and cannot be readded
  //    - remove them from mapping
  //    - emit event
  //    - decrement parentCount
  //    - add to blacklist
  //    - return true
  function removeParentFromCarpool (address parent, bool allowBlacklist)  public returns (bool){

    if(parentTrips[msg.sender].totalTripsToDo != parentTrips[msg.sender].tripsCompleted){
      if(parentTrips[msg.sender].deleteAttempt < 3){
        parentTrips[msg.sender].deleteAttempt +=1;
      emit LogWarningBlacklist(parent);
      } else {
        blacklistedParents[parent]=true;
        deleteParentMapping(parent);
      }
    }else {
      deleteParentMapping(parent);
    }

return true;
  }

 function deleteParentMapping (address parent)  private returns (){

      delete parentTrips[parent];
      parentCount = parentCount -1;
      emit LogDeleteParentFromCarpool();

  }

   function getTotalTrips (address parent)  private returns (int){

      return parentTrips[msg.sender].tripsCompleted + parentTrips[msg.sender].advanceTripsCompleted;

  }

// 1. When a parent schdules a trip, we need to decrement his trip count
//   - decrement parent trip count
//   - emit event
//   - return true
// 2. If the tripCount for the parent reaches 0
//   - they are done with their tripBlock and can relax until the next!
//   - emit event
//   - return true
// 3. Parents may want to do extra trips atfter they reach 0, to swap their scschedule with the next block 
//    - allow only maximum of 3 additional trips to add to future (so their trip count can be max -3)
//       - emit event
//       - return true
//    - if tripCount is already -3, they should not be allowed to schdule more trips 
//       - emit event
//       - return false
  function scheduleTrip(address parent) requiredTripsNotComplete() public returns (bool){

        if(globalCarpoolState == State.Start && parentTrips[msg.sender].tripState != State.Start){
          parentTrips[msg.sender].tripState = State.Start;
          parentTrips[msg.sender].totalTripsToDo = tripBlockSize / parentCount;
          parentTrips[msg.sender].tripsCompleted = 0;
          parentTrips[msg.sender].advanceTripsCompleted = 0 + parentTrips[msg.sender].advanceTripsCompleted;
          emit LogParentTripInitlized( parent);
        }
    
        if(getTotalTrips(parentTrips[msg.sender]) < parentTrips[msg.sender].totalTripsToDo ){
              parentTrips[msg.sender].tripsCompleted +=1;
              emit LogParentTrip( parent);
        }

      
      tripBlockSize = tripBlockSize-1;
      if(getTotalTrips(parentTrips[msg.sender]) == parentTrips[msg.sender].totalTripsToDo){
        parentTrips[msg.sender].tripState = State.End;
      }
      if(tripBlockSize == 0){
  //      carPoolBlockStarted=false;
  //      prevBlockCompleted = true;
        globalCarpoolState = State.End;
        emit LogEndCarpoolBlock();
      }
    
    return true;
  }

  function scheduleTripAndSwap(address parent) currentScheduleRunning() requiredTripsCompleted() public returns (bool){

        // if(parentTrips[msg.sender].tripState == State.Init){
        //   parentTrips[msg.sender].tripState = State.Start;
        //   parentTrips[msg.sender].totalTripsToDo = tripBlockSize / parentCount;
        //   parentTrips[msg.sender].tripsCompleted = 0;
        //   parentTrips[msg.sender].advanceTripsCompleted = 0;
        //   emit LogParentTripInitlized( parent);
        // }
        // if(parentTrips[msg.sender].tripState == State.End && carPoolBlockStarted){
        //   parentTrips[msg.sender].tripState = State.Start;
        //   parentTrips[msg.sender].totalTripsToDo = tripBlockSize / parentCount;
        //   if(parentTrips[msg.sender].advanceTripsCompleted !=0)
        //   parentTrips[msg.sender].tripsCompleted = 0 + parentTrips[msg.sender].advanceTripsCompleted;
        //   parentTrips[msg.sender].advanceTripsCompleted = 0;
        //   emit LogParentTripInitlized( parent);
        // }
         if (parentTrips[msg.sender].advanceTripsCompleted < MAX_ADVANCETRIPS){
              parentTrips[msg.sender].advanceTripsCompleted +=1;
              parentTrips[parent].tripsCompleted -=1; 
              emit LogAdvanceParentTrip( parent);
        } else{
              revert("Can do any more additional trips");
            }

      
      tripBlockSize = tripBlockSize-1;
      if(getTotalTrips() == parentTrips[msg.sender].totalTripsToDo ){
        parentTrips[msg.sender].tripState = State.End;
      }
      if(tripBlockSize == 0){
       globalCarpoolState = State.End;
       emit LogEndCarpoolBlock();
      }
    
    return true;
  }

// Start the new carpoolBlock when the trips in allocated block are completed
// 1. Calculate carpoolblock based on the number of parents
// 2. Initialize the tripCount of the parents to their currentValue + new schduled trips
// 3. If the total tripCount exceeds maxValue meaning the parents are not contributing to carpool
//    - remove parent with blacklisted=true
//    - emit event
// 4. Emit event
 function startCarpoolBlock() isOwner(msg.sender) public {

 // carPoolBlockStarted=true;
  globalCarpoolState = State.Start;
  int maxTripsWeek = 5;
  for(int i=1;i<MAXPARENTS;i++){
   if(maxTripsWeek % parentCount ==0){
    tripBlockSize = maxTripsWeek;
  } else {
    maxTripsWeek = maxTripsWeek * (i+1);
  }
 }
   emit LogStartCarpoolBlock();
  }
}
