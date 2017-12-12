pragma solidity ^0.4.18;
import "./Event.sol";
//["0xca35b7d915458ef540ade6068dfe2f44e8fa733c",  "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c", "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db"]
contract CompetitionManagement{
    struct User {
        string name;
        string login;
        string password;
        bool isRegistered;
    }
    
    
    mapping(address => User) _users;
    mapping(address => bool) _experts;
    
    Event[] _events;
    
    function CompetitionManagement(address[] creators) public {
        // Number of experts should be greater/equal 3
        require(creators.length >= 3);
        
        // Add addresses as experts
        for(uint i=0; i<creators.length; i++){
            _experts[creators[i]] = true;
        }
    }
    
    function createEvent(uint competence_start_date, string competence_name, address[] expert_list, address[] participant_list) public onlyExpert {
        // Check all requirements
        // All addresses should be experts
        for (uint i=0; i<expert_list.length;i++){
            require(_experts[expert_list[i]] == true);
        }
        // All participants should not be experts && registered ?
        for (i=0; i<expert_list.length;i++){
            require(_experts[participant_list[i]] == false);
        }
        // Form Event data structure
        Event newEvent = new Event(competence_name, now, competence_start_date, competence_name, expert_list, participant_list);
        
        // Add new Event
        _events.push(newEvent);
    }

    // Modifiers
    
    modifier onlyExpert {
        require(_experts[msg.sender] == true);
        _;
    }
}