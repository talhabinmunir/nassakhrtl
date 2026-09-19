# Tashkeel (Arabic diacritization), Phase 1 - online engine only.
#
# No network here. HfTashkeelEngine's wire format was confirmed against the
# live Space (see the block comment on the class); these tests cover the
# logic around it: the merge that protects the user's line structure, the
# failure paths, the ITashkeelEngine seam, DPAPI storage, and the defaults.
. (Join-Path $PSScriptRoot 'lib.ps1')
Import-NassakhEngine

# base letters, no harakat
$BSM  = [string][char]0x628 + [char]0x633 + [char]0x645                      # bsm
$ALLH = [string][char]0x627 + [char]0x644 + [char]0x644 + [char]0x647        # allh
$RB   = [string][char]0x631 + [char]0x628                                    # rb
$FATHA = [char]0x64E; $KASRA = [char]0x650; $DAMMA = [char]0x64F
$SUKUN = [char]0x652; $SHADDA = [char]0x651

# "bsm allh" with harakat, as the service returns it
$DIA = [string][char]0x628 + $KASRA + [char]0x633 + $SUKUN + [char]0x645 + $KASRA + ' ' + `
       [char]0x627 + [char]0x644 + [char]0x644 + $SHADDA + [char]0x647 + $KASRA
$PLAIN = $BSM + ' ' + $ALLH

Section "Character classes"
Check "Arabic letters recognised" ([RTLFixer.Tashkeel]::IsArabicLetter([char]0x628) -and [RTLFixer.Tashkeel]::IsArabicLetter([char]0x64A))
Check "tatweel is NOT a letter (service strips it)" (-not [RTLFixer.Tashkeel]::IsArabicLetter([char]0x640))
Check "harakat recognised (fatha, kasra, shadda, sukun, dagger alef)" ([RTLFixer.Tashkeel]::IsHaraka($FATHA) -and [RTLFixer.Tashkeel]::IsHaraka($KASRA) -and [RTLFixer.Tashkeel]::IsHaraka($SHADDA) -and [RTLFixer.Tashkeel]::IsHaraka($SUKUN) -and [RTLFixer.Tashkeel]::IsHaraka([char]0x670))
Check "letters are not harakat" (-not [RTLFixer.Tashkeel]::IsHaraka([char]0x628))
Check "StripHarakat removes only the marks" ([RTLFixer.Tashkeel]::StripHarakat($DIA) -eq $PLAIN)
Check "CountHarakat counts them (5: kasra, sukun, kasra, shadda, kasra)" ([RTLFixer.Tashkeel]::CountHarakat($DIA) -eq 5)
Check "HasArabicLetter: true for Arabic, false for Latin/empty" ([RTLFixer.Tashkeel]::HasArabicLetter($PLAIN) -and -not [RTLFixer.Tashkeel]::HasArabicLetter('Hello 2024') -and -not [RTLFixer.Tashkeel]::HasArabicLetter(''))

Section "Merge - the service destroys structure, so we re-attach marks to the ORIGINAL"
# Verified live: remove_non_arabic() strips tashkeel/tatweel, replaces every
# non-letter with a space and collapses whitespace. A two-line input with
# digits and Latin came back as one line of Arabic only.
$added = 0
$m = [RTLFixer.Tashkeel]::Merge($PLAIN, $DIA, [ref]$added)
Check "simple merge returns the diacritized text" ($m -eq $DIA)
Check "reports the number of marks added" ($added -eq 5)

$multi = $BSM + "`n" + $ALLH                       # newline the service would eat
$m = [RTLFixer.Tashkeel]::Merge($multi, $DIA, [ref]$added)
Check "NEWLINE survives the merge" ($m -ne $null -and $m.Contains("`n"))
Check "and the line order is intact" ($m -ne $null -and [RTLFixer.Tashkeel]::StripHarakat($m) -eq $multi)

$rich = $BSM + ' 2024 (Hello) ' + $ALLH
$m = [RTLFixer.Tashkeel]::Merge($rich, $DIA, [ref]$added)
Check "digits, Latin and punctuation all survive" ($m -ne $null -and $m.Contains('2024') -and $m.Contains('Hello') -and $m.Contains('('))
Check "stripping the marks gives back the exact original" ($m -ne $null -and [RTLFixer.Tashkeel]::StripHarakat($m) -eq $rich)

$tatweel = $BSM + [char]0x640 + ' ' + $ALLH
$m = [RTLFixer.Tashkeel]::Merge($tatweel, $DIA, [ref]$added)
Check "tatweel is preserved even though the service drops it" ($m -ne $null -and $m.Contains([string][char]0x640))

$already = $BSM + $FATHA + ' ' + $ALLH
$m = [RTLFixer.Tashkeel]::Merge($already, $DIA, [ref]$added)
Check "existing harakat are replaced, not doubled" ($m -eq $DIA)

Section "Merge - refuses rather than guessing"
Check "letters disagree -> null" ([RTLFixer.Tashkeel]::Merge(($RB + ' ' + $ALLH), $DIA, [ref]$added) -eq $null)
Check "reply has too few letters -> null" ([RTLFixer.Tashkeel]::Merge(($PLAIN + ' ' + $RB), $DIA, [ref]$added) -eq $null)
Check "reply has too many letters -> null" ([RTLFixer.Tashkeel]::Merge($BSM, $DIA, [ref]$added) -eq $null)
Check "null arguments -> null" (([RTLFixer.Tashkeel]::Merge($null, $DIA, [ref]$added) -eq $null) -and ([RTLFixer.Tashkeel]::Merge($PLAIN, $null, [ref]$added) -eq $null))
Check "a mark with no letter -> null" ([RTLFixer.Tashkeel]::Merge($PLAIN, ([string]$FATHA + $DIA), [ref]$added) -eq $null)

Section "Apply - failure paths leave the caller with nothing to paste"
$stub = [RTLFixer.StubTashkeelEngine]::Returning($DIA)
$r = [RTLFixer.Tashkeel]::Apply($stub, $PLAIN, [ref]$added)
Check "success returns merged text and calls the engine once" ($r -eq $DIA -and $stub.Calls -eq 1)
Check "the engine received the original text verbatim" ($stub.LastInput -eq $PLAIN)

function Fails($engine, $text) {
    # (no ternary in Windows PowerShell 5.1; .NET exceptions arrive wrapped)
    try { $null = [RTLFixer.Tashkeel]::Apply($engine, $text, [ref]$added); return $null }
    catch {
        $ex = $_.Exception
        if ($ex.InnerException) { return $ex.InnerException.Message }
        return $ex.Message
    }
}
$msg = Fails ([RTLFixer.StubTashkeelEngine]::Failing("Couldn't reach the diacritization service - check your connection.")) $PLAIN
Check "engine failure surfaces the toast text" ($msg -eq "Couldn't reach the diacritization service - check your connection.")
$msg = Fails ([RTLFixer.StubTashkeelEngine]::Returning('')) $PLAIN
Check "empty reply (a cold Space answers with an empty string) is a failure" ($msg -ne $null -and $msg.Contains('returned nothing'))
$msg = Fails ([RTLFixer.StubTashkeelEngine]::Returning($null)) $PLAIN
Check "null reply is a failure" ($msg -ne $null)
$msg = Fails ([RTLFixer.StubTashkeelEngine]::Returning(($DIA + ' ' + $RB))) $PLAIN
Check "misaligned reply is a failure, nothing pasted" ($msg -ne $null -and $msg.Contains('did not line up'))
$msg = Fails $null $PLAIN
Check "no engine configured is a failure" ($msg -ne $null)
$e2 = [RTLFixer.StubTashkeelEngine]::Returning($DIA)
$msg = Fails $e2 'Hello 2024'
Check "non-Arabic input fails WITHOUT calling the service" ($msg -ne $null -and $e2.Calls -eq 0)

Section "ITashkeelEngine is the only seam (Phase 2 can swap in an offline engine)"
$iface = [RTLFixer.ITashkeelEngine]
Check "HfTashkeelEngine implements ITashkeelEngine" ($iface.IsAssignableFrom([RTLFixer.HfTashkeelEngine]))
Check "StubTashkeelEngine implements it too" ($iface.IsAssignableFrom([RTLFixer.StubTashkeelEngine]))
Check "Apply takes the interface, not a concrete engine" (([RTLFixer.Tashkeel].GetMethod('Apply').GetParameters()[0].ParameterType) -eq $iface)
$flags = [Reflection.BindingFlags]'NonPublic,Instance'
$fld = [RTLFixer.MainForm].GetField('tashkeelEngine', $flags)
Check "MainForm holds the engine as ITashkeelEngine" ($fld -ne $null -and $fld.FieldType -eq $iface)
# the only place the concrete engine may be named is where it is constructed
$src = [IO.File]::ReadAllText((Join-Path (Split-Path -Parent $PSScriptRoot) 'NassakhRTL.ps1'))
$hits = ([regex]::Matches($src, 'new HfTashkeelEngine')).Count
Check "HfTashkeelEngine is constructed in exactly one place" ($hits -eq 1)
Check "no call site invokes HfTashkeelEngine.Diacritize directly" (-not $src.Contains('HfTashkeelEngine.Diacritize'))

Section "HTTP shape (confirmed against the live Space)"
Check "host is the Space, not the Inference API" ([RTLFixer.HfTashkeelEngine]::Host -eq 'https://mohamedrashad-arabic-auto-tashkeel.hf.space')
Check "CATT endpoint, never Shakkala" (([RTLFixer.HfTashkeelEngine]::ApiName -eq 'infer_catt') -and -not $src.Contains('infer_shakkala'))
Check "default model is Encoder-Decoder" ([RTLFixer.HfTashkeelEngine]::ModelEncoderDecoder -eq 'Encoder-Decoder')
$eng = New-Object RTLFixer.HfTashkeelEngine('')
Check "default timeout is 8s" ($eng.TimeoutMs -eq 8000)
Check "JsonString escapes Arabic and control chars" ([RTLFixer.HfTashkeelEngine]::JsonString("a`nb") -eq '"a\nb"')
Check "ExtractField reads event_id" ([RTLFixer.HfTashkeelEngine]::ExtractField('{"event_id":"abc123"}', 'event_id') -eq 'abc123')
$jsonEsc = '[' + [char]34 + '\u0628\u0633\u0645' + [char]34 + ']'   # literal backslash-u escapes
Check "FirstStringOfArray decodes backslash-u escapes in the SSE payload" ([RTLFixer.HfTashkeelEngine]::FirstStringOfArray($jsonEsc) -eq $BSM)
Check "empty array payload decodes to empty" ([RTLFixer.HfTashkeelEngine]::FirstStringOfArray('[""]') -eq '')

Section "DPAPI secret storage"
$tok = 'hf_TESTtoken_0123456789'
$enc = [RTLFixer.SecretStore]::Protect($tok)
Check "ciphertext is not the plaintext" ($enc -ne $tok -and $enc.Length -gt 0 -and -not $enc.Contains($tok))
Check "round-trips back to the token" ([RTLFixer.SecretStore]::Unprotect($enc) -eq $tok)
Check "ciphertext is base64 (safe in an ini file)" ($enc -match '^[A-Za-z0-9+/=]+$')
Check "empty in, empty out" (([RTLFixer.SecretStore]::Protect('') -eq '') -and ([RTLFixer.SecretStore]::Unprotect('') -eq ''))
Check "undecryptable input yields empty, never throws" ([RTLFixer.SecretStore]::Unprotect('bm90LWEtZHBhcGktYmxvYg==') -eq '')
Check "two encryptions of the same token differ (DPAPI entropy)" ([RTLFixer.SecretStore]::Protect($tok) -ne $enc)
Check "Mask hides the middle" (([RTLFixer.SecretStore]::Mask($tok)).StartsWith('hf_') -and -not ([RTLFixer.SecretStore]::Mask($tok)).Contains('token'))
Check "the raw token never appears in settings text" (-not $src.Contains('hf.token=" + hfToken'))

Section "Privacy: nothing is logged or persisted"
Check "no file writes in the tashkeel path" (-not ([regex]::Match($src, '(?s)class HfTashkeelEngine.*?\n\}').Value -match 'File\.|StreamWriter|AppendText'))
Check "history is not touched by the tashkeel action" (-not ([regex]::Match($src, '(?s)void DiacritizeActiveTextBox.*?\n    \}').Value -match 'PushHistory'))

Finish
