/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
describe("CreditCard", function() {
  it("cleans the number by removing spaces and dashes", function() {
    expect(CreditCard.cleanNumber("123 4-5")).toEqual("12345");
  });
});

