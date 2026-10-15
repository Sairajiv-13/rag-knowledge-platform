# Security policy

## Supported versions

The main branch is the current version of this design. Security corrections land on main. There are no other maintained branches.

## Reporting a problem

Do not open a public issue for a security problem in this design. A public issue would describe the weakness in a HIPAA aligned setup before it is corrected.

Email the report to sairn3@gmail.com. Include:

- The weakness, in plain words
- Where it sits: the file and section, for example the security group rules in `ARCHITECTURE.md` or a control mapping in `COMPLIANCE.md`
- The HIPAA control it affects, if you know it, such as §164.312(e)(1) for transmission and network protections
- What an attacker gains if the design is deployed as written

Never include real patient data, AWS account identifiers, access keys, or real endpoint values in a report. Describe the shape of the problem, not live values.

You will get a reply within three business days. If the report checks out, the documents are corrected before anything is posted in public, and you will be told when the correction is on main.
