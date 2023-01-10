Vault Contract

1)Explanation
user can deposit the money to vault(contract) and vault give/mint user specific amount of shares.
Then Vault invest that money into another def protocol and takes profit or loss.
when user withdraw its money the contract(Vault) burns its shares and gives the money he deposit +/- profit/loss faced by contract


2) Amount of shares vault mint 
d= amnt of deposit
B = initial balance of vault
s = shares to mint
T = total no of shares before mint

s= d*T/B;

3) withdraw

s = B*s/T;
