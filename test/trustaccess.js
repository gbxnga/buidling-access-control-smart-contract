const TrustAccessData = artifacts.require("TrustAccessData");

contract('TrustAccess', (accounts) => {
  it('should put register apartment', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed();

    let registeredApartment = await trustAccessDataInstance.registerApartment(accounts[1], "Ikoyi");
    // console.log({ registeredApartment });
 
  });

  it('should fetch single apartment', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed();

    let registeredApartment = await trustAccessDataInstance.registerApartment(accounts[2], "Omole Estate");
    // console.log({ registeredApartment });

    let apartment = await trustAccessDataInstance.fetchApartment(accounts[2]);
    // console.log({ apartment })
    // console.log({ name: apartment.name });

    assert.equal(apartment.name, "Omole Estate", "Apartment name returned wrong name");
 
  });

  it('should put register resident', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed();

    let registeredResident = await trustAccessDataInstance.registerResident(accounts[3], "Gbenga Oni");
    // console.log({ registeredResident });
 
  });

  it('should fetch single resident', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed();

    let registeredResident = await trustAccessDataInstance.registerResident(accounts[4], "Seun Oni");
    // console.log({ registeredResident });

    let resident = await trustAccessDataInstance.fetchResident(accounts[4]);
    // console.log({ resident })
    // console.log({ name: resident.name });

    assert.equal(resident.name, "Seun Oni", "Resident name returned wrong name");
 
  });

  it('should assign resident to apartment', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed();

    let assignements = await trustAccessDataInstance.assignResidentToApartment(accounts[3], accounts[1]);
    // console.log({ assignements });

    assignements = await trustAccessDataInstance.assignResidentToApartment(accounts[3], accounts[2]);
    // console.log({ assignements });

    let residentAssignements = await trustAccessDataInstance.fetchResidentApartments(accounts[3]);
    // console.log({ residentAssignements });
 
 
  });

  it('resident can make appointment', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed(); 

    let visitorsAddress = accounts[6];
    let residentAddress = accounts[3];
    let time = "1289";
    let apartmentAddress = accounts[1];
    await trustAccessDataInstance.makeAppointment( 
        apartmentAddress,
        visitorsAddress,
        time, 
        {from: residentAddress} 
    ); 
    


    await trustAccessDataInstance.makeAppointment( 
        accounts[1],
        visitorsAddress,
        "1234", 
        {from: residentAddress}
    );
    await trustAccessDataInstance.makeAppointment( 
        accounts[2],
        visitorsAddress,
        "0987", 
        {from: residentAddress}
    ); 
 
 

    let appointmentVerified =  await trustAccessDataInstance.verifyAppointment(
        visitorsAddress,
        time,
        apartmentAddress,

        {from: residentAddress}
    );

    assert.equal(appointmentVerified, true, "Appointment must be verified"); 

    appointmentVerified =  await trustAccessDataInstance.verifyAppointment(
        visitorsAddress,
        "9899", // chenage to worng time
        apartmentAddress,

        {from: residentAddress}
    );

    assert.equal(appointmentVerified, false, "Appointment should be unverified"); 

    let appointmentCount = await trustAccessDataInstance.appointmentCount(); 

    assert.equal(appointmentCount.toNumber(), 3, "Appointment count should be 3");

  });

  it('can fetch appointments count', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed(); 
 
 
    let appointmentCount = await trustAccessDataInstance.appointmentCount();
    console.log({ appointmentCount: appointmentCount.toNumber() });
 
  });

  it('can fetch residents count', async () => {
    const trustAccessDataInstance = await TrustAccessData.deployed(); 
 
 
    let residentCount = await trustAccessDataInstance.residentCount();
    console.log({ residentCount: residentCount.toNumber() });
 
  });
  
});