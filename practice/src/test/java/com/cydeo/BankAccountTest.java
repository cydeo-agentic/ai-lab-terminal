package com.cydeo;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class BankAccountTest {

    @Test
    void depositAddsToTheBalance() {
        BankAccount account = new BankAccount(1_000);
        account.deposit(250);
        assertEquals(1_250, account.getBalanceCents());
    }
}
