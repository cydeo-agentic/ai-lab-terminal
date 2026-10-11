package com.cydeo;

/** A tiny bank account to practice on. Ask the agent to test it, then find the bug. */
public class BankAccount {
    private long balanceCents;

    public BankAccount(long openingBalanceCents) {
        if (openingBalanceCents < 0) throw new IllegalArgumentException("opening balance cannot be negative");
        this.balanceCents = openingBalanceCents;
    }

    public long getBalanceCents() {
        return balanceCents;
    }

    public void deposit(long amountCents) {
        if (amountCents <= 0) throw new IllegalArgumentException("deposit must be positive");
        balanceCents += amountCents;
    }

    /** Withdraws the amount if the balance covers it. */
    public void withdraw(long amountCents) {
        if (amountCents <= 0) throw new IllegalArgumentException("withdrawal must be positive");
        if (amountCents >= balanceCents) throw new IllegalStateException("insufficient funds");
        balanceCents -= amountCents;
    }
}
