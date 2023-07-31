const Ticket1155 = artifacts.require("Ticket1155");

contract("Ticket1155", async (accounts) => {

    it("should mint tickets", async () => {
        const contract = await Ticket1155.deployed();
        
        const ticketName = "TestTicket";
        const ticketPrice = web3.utils.toWei("0.01", "ether");
        const ticketAmount = 10;
        const limitTime = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

        await contract.mintTicket(limitTime, ticketPrice, ticketAmount, ticketAmount, ticketName, { from: accounts[0] });

        const ticketInfo = await contract.getTicketInfo(1);
        assert.equal(ticketInfo.ticketName, ticketName);
        assert.equal(ticketInfo.price, ticketPrice);
        assert.equal(ticketInfo.limitAmount, ticketAmount.toString());
        assert.equal(ticketInfo.limitTime, limitTime.toString());
    });

    it("should purchase ticket", async () => {
        const contract = await Ticket1155.deployed();

        const ticketId = 1;
        const ticketAmount = 1;
        const ticketPrice = web3.utils.toWei("0.01", "ether");

        await contract.buyTicket(ticketId, ticketAmount, { from: accounts[1], value: ticketPrice });

        const balance = await contract.balanceOf(accounts[1], ticketId);
        assert.equal(balance.toString(), ticketAmount.toString());
    });

    it("should not allow purchase of expired ticket", async () => {
        const contract = await Ticket1155.deployed();
    
        const ticketName = "ExpiredTicket";
        const ticketPrice = web3.utils.toWei("0.01", "ether");
        const ticketAmount = 10;
        const limitTime = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
    
        await contract.mintTicket(limitTime, ticketPrice, ticketAmount, ticketAmount, ticketName, { from: accounts[0] });
        const ticketId = (await contract.getTicketIndex()).toNumber() - 1;
    
        try {
            await contract.buyTicket(ticketId, ticketAmount, { from: accounts[1], value: ticketPrice });
            assert.fail("Expected revert not received");
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    });    

    it("should burn tickets upon use", async () => {
        const contract = await Ticket1155.deployed();

        const ticketId = 1;
        const initialBalance = await contract.balanceOf(accounts[1], ticketId);
        assert.ok(initialBalance > 0);

        await contract.useTicket(ticketId, { from: accounts[1] });

        const finalBalance = await contract.balanceOf(accounts[1], ticketId);
        assert.equal(finalBalance.toString(), (initialBalance - 1).toString());
    });

    it("should not allow ticket use after expiry", async () => {
        const contract = await Ticket1155.deployed();
    
        const ticketName = "TestTicket";
        const ticketPrice = web3.utils.toWei("0.01", "ether");
        const ticketAmount = 10;
        const limitTime = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
    
        await contract.mintTicket(limitTime, ticketPrice, ticketAmount, ticketAmount, ticketName, { from: accounts[0] });
    
        const ticketId = (await contract.getTicketIndex()).toNumber() - 1;
    
        // Make sure account[1] has enough Ether
        const balance = await web3.eth.getBalance(accounts[1]);
        assert(web3.utils.toBN(balance).gte(web3.utils.toBN(ticketPrice)), "account[1] does not have enough Ether");
    
        // Buy the ticket
        await contract.buyTicket(ticketId, 1, { from: accounts[1], value: ticketPrice });
    
        // Now we'll try to use the ticket. Since the ticket is expired, this should fail.
        try {
            await contract.useTicket(ticketId, { from: accounts[1] });
            assert.fail("Expected revert not received");
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    });    

    it("should return correct ticket info for owner", async () => {
        const contract = await Ticket1155.deployed();

        const ticketName = "TestTicket";
        const ticketPrice = web3.utils.toWei("0.01", "ether");
        const ticketAmount = 10;
        const limitTime = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

        await contract.mintTicket(limitTime, ticketPrice, ticketAmount, ticketAmount, ticketName, { from: accounts[0] });
        const ticketId = (await contract.getTicketIndex()).toNumber() - 1;

        const ticketInfo = await contract.getTicketInfo(ticketId, { from: accounts[0] });
        assert.equal(ticketInfo.ticketName, ticketName);
        assert.equal(ticketInfo.price, ticketPrice);
        assert.equal(ticketInfo.limitAmount, ticketAmount.toString());
        assert.equal(ticketInfo.limitTime, limitTime.toString());
    });

    it("should return limited ticket info for non-owner", async () => {
        const contract = await Ticket1155.deployed();

        const ticketId = 1;
        await contract.buyTicket(ticketId, 1, { from: accounts[1], value: web3.utils.toWei("0.01", "ether") });

        const ticketInfo = await contract.getTicketInfo(ticketId, { from: accounts[1] });
        assert.equal(ticketInfo.ticketName, "TestTicket");
        assert.ok(ticketInfo.limitTime > 0);
        assert.equal(ticketInfo.price, '0');
        assert.equal(ticketInfo.limitAmount, '0');
    });
});
