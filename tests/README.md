# Tests

No automated tests are included in this initial release. If you add Pester tests,
this is the expected location (`tests/*.Tests.ps1`), following standard PowerShell
module conventions.

Given that three of the four functions in this module shell out to `slmgr.vbs` and
make or verify real licensing state, meaningful unit tests would need to mock
`cscript.exe` output rather than run against a live machine. That mocking layer
is a reasonable follow-up contribution but wasn't part of the original blog post,
so it's left out of this initial release rather than added speculatively.
