import Lake
open Lake DSL

package conjectureA1Offline

/-- Offline proof target. Imports are read from the supplied read-only LEAN_PATH;
all generated proof artifacts stay under this package's build directory. -/
@[default_target]
target proofcheck pkg : Unit := do
  Job.async do
    let outDir := pkg.buildDir / "lib" / "lean"
    IO.FS.createDirAll outDir
    let lean := (← IO.getEnv "A1_LEAN").getD "lean"
    let paths := (← IO.getEnv "LEAN_PATH").getD ""
    let sep := if System.Platform.isWindows then ";" else ":"
    for name in #["ConjectureA1", "SpecialCases", "VectorCases", "BoundaryCases", "NormalOrder", "AxiomAudit"] do
      let result ← IO.Process.output {
        cmd := lean
        args := #["-o", (outDir / s!"{name}.olean").toString,
          (pkg.dir / s!"{name}.lean").toString]
        env := #[("LEAN_PATH", some (outDir.toString ++ sep ++ paths))] }
      IO.print result.stdout
      IO.eprint result.stderr
      if result.exitCode != 0 then
        error s!"{name}: Lean exited {result.exitCode}"
      IO.println s!"CHECKED {name}"
