import { expect } from 'chai';
import { ethers } from 'hardhat';

let token: Contract;

before(async () => {
  const factory = await ethers.getContractFactory('TextSplitTest');
  token = await factory.deploy();
});

describe('TextSplit', function () {
  it('Text 2 Array', async function () {
    const text = 'this is test';
    const result = await token.splitOnNewline(text);
    expect(result.length).equal(1);
    expect(result).to.deep.equal(text.split('\n'));
    console.log(result);
  });

  it('Text with new line 2 Array', async function () {
    const text = 'This\nis\na\npen';
    const result = await token.splitOnNewline(text);
    expect(result.length).equal(4);
    console.log(result);
    expect(result).to.deep.equal(text.split('\n'));
  });

  it('Text sandwiched between newlines 2 Array', async function () {
    const text = '\nThis\nis\na\npen\n';
    const result = await token.splitOnNewline(text);
    console.log(result);
    expect(result.length).equal(6);
    expect(result).to.deep.equal(text.split('\n'));
  });
  
  it('Long Text 2 Array', async function () {
    const text = [
      '\nThisThisThisThisThisThisThisThisThisThisThisThisThisThis\nis\na\npen\n',
      '\nThisThisThisThisThisThisThisThisThisThisThisThisThisThis\nis\na\npen\n',
      '\nThisThisThisThisThisThisThisThisThisThisThisThisThisThis\nis\na\npen\n',
      '\nThisThisThisThisThisThisThisThisThisThisThisThisThisThis\nis\na\npen',
    ].join("\n");
    const result = await token.splitOnNewline(text);
    console.log(result);
    // expect(result.length).equal(6);
    expect(result).to.deep.equal(text.split('\n'));
  });


});
