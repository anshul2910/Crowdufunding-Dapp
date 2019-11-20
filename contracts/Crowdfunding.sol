pragma solidity 0.5.4;
import 'https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Crowdfunding {
    
    using SafeMath for uint256; 
    Project[] private projects; //Array to store list of existing projects4

    event ProjectStarted( //event that will be emitted everytime a new project is strated.

        address contractAddress,
        address projectStarter,
        string projectTitle,
        string projectDesc,
        uint256 deadline,
        uint256 goalAmount
    );

    function startProject(
        string calldata title,  //title of the project.
        string calldata description, //Description of the project.
        uint durationInDays, //number of days for which project would be open for funding.
        uint amountToRaise   //total amount of money to be raised for the funding.

    ) external {

        uint raiseUntil = now.add(durationInDays.mul(1 days));
        Project newProject = new Project(msg.sender, title, description, raiseUntil, amountToRaise);
        projects.push(newProject);
    
        emit ProjectStarted( //Triggering the event.
            address(newProject),
            msg.sender,
            title,
            description,
            raiseUntil,
            amountToRaise
        );
    }

    // function to return the contact address of all projects.
    //declared externally, as it can be called by other contracts.

    function returnAllProjects() external view returns (Project[] memory){ //other contracts and transaction can call this function.
        return projects;
    }
}

contract Project {

    using SafeMath for uint256;

    enum State {

        Fundraising,
        Expired,
        Successful
    }

    //Declaring State Variables.

    address payable public creator;
    uint public amountGoal;
    uint public completeAt;
    uint256 public currentBalance;
    uint public raiseBy;
    string public title;
    string public description;
    
    State public state = State.Fundraising; // initialise on create
    mapping (address => uint ) public contributions;

    event fundingRecieved (address contributor, uint amount, uint currentTotal);
    //event to be emitted whenever a funding will be recieved.

    event creatorPaid (address recipient);
    //event to be emitted whenever project starter has recieved the funds.

    modifier inState(State _state){ //function modifier to check the current state

        require(state == state);
        _;

    }

    modifier isCreator() { //function modifier to check if function caller is creator.

        require(msg.sender == creator);

    }

    constructor (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        uint fundRaisingDeadine,
        uint goalAmount

    ) public {

        creator = projectStarter;
        title = projectTilte;
        description = projectDesc;
        amountGoal = goalAmount;
        raiseBy = fundRaisingDeadline;
        currentBalance = 0;
    }


    function contribute() external inState(State.Fundraising) payable {

        require(msg.sender != creator); //creator can't raise fund for himself.
        contributions[msg.sender] = con


    }

    
}

