pragma solidity ^0.4.18;
import "./Event.sol";
//["0xca35b7d915458ef540ade6068dfe2f44e8fa733c",  "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c", "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db"]
//"A", 124, "B", ["0xca35b7d915458ef540ade6068dfe2f44e8fa733c"], []
//"0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "A", 124, "B", ["0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c"], []
contract CompetitionManagement{
    // Constants
    uint NOMINATION_TIME = 1 days;

    struct User {
        string name;
        string login;
        string password;
        bool isRegistered;
    }

    struct NominationToExpert{
        uint creation_time;
        address user;
        bool isAccepted;
        bool isDue;
        uint acceptanceCount;
    }

    struct NominationToUser{
        uint creation_time;
        address user;
        bool isAccepted;
        bool isDue;
        uint acceptanceCount;
    }

    mapping(address => User) _users;
    mapping(address => bool) _experts;

    address[] public _events;

    function CompetitionManagement(address[] creators) public {
        // Number of experts should be greater/equal 3
        require(creators.length >= 3);

        // Add addresses as experts
        for(uint i=0; i<creators.length; i++){
            _experts[creators[i]] = true;
        }
    }

    function createEvent(string name, uint competence_start_date, string competence_name, address[] expert_list, address[] participant_list) public onlyExpert {
        // Check all requirements
        // All addresses should be experts && creator in expert list
        bool isExpertInList = false;
        for (uint i=0; i<expert_list.length;i++){
            require(_experts[expert_list[i]] == true);
            if(expert_list[i] == msg.sender){
                isExpertInList = true;
            }
        }
        require(isExpertInList);

        // All participants should not be experts && registered ?
        for (i=0; i<participant_list.length;i++){
            require(_experts[participant_list[i]] == false);
        }
        // Form Event data structure
        Event newEvent = new Event(name, now, competence_start_date, competence_name, expert_list, participant_list);

        // Add new Event
        _events.push(address(newEvent));
    }

    function changeEvent(address event_address, string name, uint start_date, string competence, address[] expert_list, address[] participant_list) public{
        Event currentEvent = findEventByAddress(event_address);
        currentEvent.changeEvent(msg.sender, name, start_date, competence, expert_list, participant_list);

    }

    function submitEventEddition(address event_address) public returns(bool) {
        Event currentEvent = findEventByAddress(event_address);
        return currentEvent.submitAcceptence(msg.sender);
    }

    // Modifiers
    function findEventByAddress(address event_address) private returns(Event){
        bool eventIsFound = false;
        for(uint i=0; i<_events.length; i++){
            if(_events[i] == event_address){
                eventIsFound = true;
                return Event(_events[i]);
            }
        }
        require(eventIsFound);
    }
    modifier onlyExpert {
        require(_experts[msg.sender] == true);
        _;
    }
}