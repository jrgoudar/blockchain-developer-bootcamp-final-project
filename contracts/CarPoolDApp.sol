
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  address public owner;

  uint public parentCount;

  uint public tripBlockSize;

  mapping(address => uint) parentTrips;

  mapping(address => bool) blacklistedParents;
  
  /* 
   * Events
   */

  event LogParentTrip(address parent);

  event LogAddParentToCarPool(address parent);

  event LogDeleteParentFromCarpool(address parent);

 event LogAddParentToBlacklist(address parent);

  

  constructor() public {
    owner = msg.sender;
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
  function addParentToCarpool(address parent) public returns (bool) {
    
    
    return true;
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
  function removeParentFromCarpool(address parent, bool allowBlacklist) public returns (bool){

return true;
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
  function scheduleTrip(address parent) public returns (bool){

    return true;
  }

// Start the new carpoolBlock when the trips in allocated block are completed
// 1. Calculate carpoolblock based on the number of parents
// 2. Initialize the tripCount of the parents to their currentValue + new schduled trips
// 3. If the total tripCount exceeds maxValue meaning the parents are not contributing to carpool
//    - remove parent with blacklisted=true
//    - emit event
// 4. Emit event
 function startCarpoolBlock() public {

  }
}
