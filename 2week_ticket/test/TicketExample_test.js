const Ticket = artifacts.require('Ticket');
const truffleAssert = require('truffle-assertions');

contract('Ticket', (accounts) => {
    let ticket;
    const owner = accounts[0];
    const buyer = accounts[1];

    before(async () => {
        ticket = await Ticket.new({from: owner});
    });

    it('should mint a ticket', async () => {
        await ticket.mintTicket(buyer, 1, 1688137200, 1690729200, 5, web3.utils.toWei('0.01', 'ether'), "A1", "https://dev-internship.s3.ap-northeast-2.amazonaws.com/test/1.json", {from: owner});
        let ticketInfo = await ticket.getTicketInfo(1);
        assert.equal(ticketInfo.price, web3.utils.toWei('0.01', 'ether'));
        assert.equal(ticketInfo.seatNumber, 'A1');
    });

    it('should buy a ticket', async () => {
        await ticket.buyTicket(1, {from: buyer, value: web3.utils.toWei('0.01', 'ether')});
        let newOwner = await ticket.ownerOf(1);
        assert.equal(newOwner, buyer);
    });

    it('should use a ticket', async () => {
        await truffleAssert.reverts(ticket.useTicket(1, {from: owner}), "Caller is not owner nor approved");
        await ticket.useTicket(1, {from: buyer});
        let ticketInfo = await ticket.getTicketInfo(1);
        assert.equal(ticketInfo.uses, 4);
    });

    it('should burn a ticket', async () => {
        await truffleAssert.reverts(ticket.burnTicket(1, {from: owner}), "ERC721: burn caller is not owner nor approved");
        await ticket.burnTicket(1, {from: buyer});
        await truffleAssert.reverts(ticket.getTicketInfo(1), "revert");
    });
});