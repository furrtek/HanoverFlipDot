; Hanover Displays 84x7 flip-dot display program disassembly
; Dumped from a 8kB 8bit EPROM
; By furrtek 10/2017

; Input MD5   : 383B260C543F04F24B22DCF325C4107B
; Input CRC32 : 6D5C23D8
; File Name   : flipdot.bin
; Format      : Binary file
; Base Address: 0000h Range: 0000h - 2000h Loaded length: 00002000h
; Processor:    M6502 (extended!)

REGS:0000 ; ===========================================================================
REGS:0000 ; Segment type: Regular
REGS:0000                 ;.segment REGS
REGS:0000 PORTA
REGS:0001 PORTB
REGS:0002 PORTC
REGS:0003 PORTD
REGS:0012 IRQCFG
REGS:0014 MODECTRL
REGS:0015 SERIALCFG
REGS:0017 SERIALDATA
REGS:0018 TIMERA_LOW
REGS:001A TIMERA_HIGH

RAM:0040 ; ===========================================================================
RAM:0040 ; Segment type: Regular
RAM:0040                 ;.segment RAM
RAM:0040 RAMSTART
RAM:0041 FLAGS
RAM:0042 PortCValue
RAM:0043 CurTextBufferBase
RAM:005B CharIndex
RAM:005C WordVarLow
RAM:005D WordVarHigh
RAM:005E CharLength
RAM:0062 byte_62
RAM:0063 PIXELS
RAM:0064 DotIndex
RAM:0065 ColumnIndex?
RAM:0066 FontIndex
RAM:0067 PercentCharPos
RAM:0068 TotalColumnCount
RAM:0069 PaddingLeft
RAM:006A PaddingRight
RAM:006B unk_6B
RAM:006C unk_6C
RAM:006D SpecialChar?
RAM:006E CurCharIndex
RAM:006F CurrentRXState
RAM:0070 JumpLSB
RAM:0071 JumpMSB
RAM:0072 MessagePtr
RAM:0073 MessageLength
RAM:0074 RxChecksum
RAM:00FF ; end of 'RAM'

EXTRAM:2000 ; ===========================================================================
EXTRAM:2000 ; Segment type: Regular
EXTRAM:2000                 ;.segment EXTRAM
EXTRAM:2000 CurMsgBufferBase
EXTRAM:2100 RxMsgBufferBase
EXTRAM:3FFF ; end of 'EXTRAM'

ROM:E000 ; ---------------------------------------------------------------------------
ROM:E000 ; ===========================================================================
ROM:E000 ; Segment type: Regular
ROM:E000                 ;.segment ROM
ROM:E000 RESET:
ROM:E000                 LDX     #$FF
ROM:E002                 TXS                     ; Stack ptr at end of zero page
ROM:E003                 CLD
ROM:E004                 SEI                     ; Disable interrupts
ROM:E005                 LDA     #$20
ROM:E007                 STA     MODECTRL        ; Full address mode, port D hi-z, interval timers
ROM:E009                 LDX     #60
ROM:E00B                 LDA     #0
ROM:E00D
ROM:E00D ClearRAM:
ROM:E00D                 STA     RAMSTART,X
ROM:E00F                 DEX
ROM:E010                 BPL     ClearRAM
ROM:E012                 LDA     #0              ; Ports A, B and D as outputs
ROM:E014                 STA     PORTA
ROM:E016                 STA     PORTB
ROM:E018                 STA     PORTD
ROM:E01A                 LDA     #$F             ; Lower 4 bits of port C as inputs (address setting, ignored)
ROM:E01C                 STA     PORTC
ROM:E01E                 STA     PortCValue
ROM:E020                 LDA     #$C             ; 2MHz / 2 (prescaler) / 16 (fixed) / (12 + 1) =~ 4800bps
ROM:E022                 STA     TIMERA_LOW
ROM:E024                 LDA     #0
ROM:E026                 STA     TIMERA_HIGH
ROM:E028                 LDA     #$C2            ; TX en, RX en, ASYNC mode, 8-odd-1, parity en
ROM:E02A                 STA     SERIALCFG
ROM:E02C                 LDA     #$40            ; IRQ on serial rx
ROM:E02E                 STA     IRQCFG
ROM:E030                 RLA     RAMSTART        ; RMB2
ROM:E032                 JSR     ClearDisplay
ROM:E035                 LAX     RAMSTART        ; SMB2
ROM:E037                 CLI
ROM:E038
ROM:E038 MainLoop:
ROM:E038                 JSR     DoClock
ROM:E03B                 ISB     $941,X          ; Branch if bit7 = 1
ROM:E03E                 DCP     $C40            ; Branch if bit4 = 1
ROM:E041                 SAX     $1340           ; Branch if bit0 = 1
ROM:E044                 JMP     MainLoop
ROM:E047 ; ---------------------------------------------------------------------------
ROM:E047                 JSR     TxErrorCode
ROM:E04A                 JMP     MainLoop
ROM:E04D ; ---------------------------------------------------------------------------
ROM:E04D                 JSR     CopyRxBuffer    ; RAMSTART bit4 = 1: Update display !
ROM:E050                 SRE     RAMSTART        ; Clear bit4
ROM:E052                 SAX     RAMSTART        ; Set bit0
ROM:E054                 JMP     MainLoop
ROM:E057 ; ---------------------------------------------------------------------------
ROM:E057                 JMP     UpdateDisplay   ; RAMSTART bit0 = 1: Update display !
ROM:E05A
ROM:E05A ; =============== S U B R O U T I N E =======================================
ROM:E05A
ROM:E05A ; Copies rx buffer in external SRAM
ROM:E05A
ROM:E05A CopyRxBuffer:
ROM:E05A                 LDX     #0
ROM:E05C
ROM:E05C copyloop:
ROM:E05C                 LDA     RxMsgBufferBase,X
ROM:E05F                 BEQ     endcode
ROM:E061                 STA     CurMsgBufferBase,X
ROM:E064                 INX
ROM:E065                 JMP     copyloop
ROM:E068 ; ---------------------------------------------------------------------------
ROM:E068
ROM:E068 endcode:
ROM:E068                 STA     CurMsgBufferBase,X
ROM:E06B                 RTS
ROM:E06B ; End of function CopyRxBuffer
ROM:E06B
ROM:E06C
ROM:E06C ; =============== S U B R O U T I N E =======================================
ROM:E06C
ROM:E06C
ROM:E06C WaitAndClock:
ROM:E06C                 TXA
ROM:E06D                 LDX     #200
ROM:E06F
ROM:E06F wait:
ROM:E06F                 DEX
ROM:E070                 BNE     wait
ROM:E072                 TAX
ROM:E073                 JSR     DoClock
ROM:E076                 RTS
ROM:E076 ; End of function WaitAndClock
ROM:E076
ROM:E077
ROM:E077 ; =============== S U B R O U T I N E =======================================
ROM:E077
ROM:E077
ROM:E077 DoClock:
ROM:E077                 LDA     PortCValue
ROM:E079                 EOR     #10000b
ROM:E07B                 STA     PortCValue
ROM:E07D                 STA     PORTC
ROM:E07F                 RTS
ROM:E07F ; End of function DoClock
ROM:E07F
ROM:E080 ; ---------------------------------------------------------------------------
ROM:E080
ROM:E080 UpdateDisplay:
ROM:E080                 LDA     #0
ROM:E082                 STA     CurCharIndex
ROM:E084                 RLA     $40,X           ; RMB3 $40
ROM:E086
ROM:E086 loc_E086:
ROM:E086                 JSR     DoClock
ROM:E089                 JSR     ParseSpecialChars?
ROM:E08C                 JSR     ParsePercent
ROM:E08F                 LDA     SpecialChar?
ROM:E091                 CMP     #$5E ; '^'
ROM:E093                 BNE     loc_E09D
ROM:E095                 LAX     $540,Y
ROM:E098                 SLO     RAMSTART        ; Clear bit 7
ROM:E09A                 JMP     MainLoop
ROM:E09D ; ---------------------------------------------------------------------------
ROM:E09D
ROM:E09D loc_E09D:
ROM:E09D                 LDA     #$C
ROM:E09F                 RLA     $240,X          ; BBR3
ROM:E0A2                 LDA     #8
ROM:E0A4                 STA     unk_6C
ROM:E0A6                 LAX     $40,Y
ROM:E0A8
ROM:E0A8 loc_E0A8:
ROM:E0A8                 LDA     #$FA ; '·'
ROM:E0AA                 STA     unk_6B
ROM:E0AC
ROM:E0AC loc_E0AC:
ROM:E0AC                 JSR     WaitAndClock
ROM:E0AF                 RRA     $341,X
ROM:E0B2                 JSR     TxErrorCode
ROM:E0B5                 SRE     $540            ; Branch if bit4 = 0
ROM:E0B8                 SLO     RAMSTART        ; Clear bit 7
ROM:E0BA                 JMP     MainLoop
ROM:E0BD ; ---------------------------------------------------------------------------
ROM:E0BD                 DEC     unk_6B
ROM:E0BF                 BNE     loc_E0AC
ROM:E0C1                 DEC     unk_6C
ROM:E0C3                 BNE     loc_E0A8
ROM:E0C5                 LDA     SpecialChar?
ROM:E0C7                 CMP     #$5E ; '^'
ROM:E0C9                 BNE     loc_E0CE
ROM:E0CB                 JMP     UpdateDisplay
ROM:E0CE ; ---------------------------------------------------------------------------
ROM:E0CE
ROM:E0CE loc_E0CE:
ROM:E0CE                 JMP     loc_E086
ROM:E0D1
ROM:E0D1 ; =============== S U B R O U T I N E =======================================
ROM:E0D1
ROM:E0D1
ROM:E0D1 ParseSpecialChars?:
ROM:E0D1                 LDX     CurCharIndex
ROM:E0D3                 LDY     #0
ROM:E0D5
ROM:E0D5 parsechars:
ROM:E0D5                 LDA     CurMsgBufferBase,X
ROM:E0D8                 STA     CurTextBufferBase,Y
ROM:E0DB                 BEQ     specialchar1    ; End code
ROM:E0DD                 CMP     #$5E ; '^'
ROM:E0DF                 BEQ     specialchar1
ROM:E0E1                 CMP     #$3E ; '>'
ROM:E0E3                 BEQ     specialchar2
ROM:E0E5                 INX
ROM:E0E6                 INY
ROM:E0E7                 CPY     #23             ; 22 chars max ?
ROM:E0E9                 BNE     parsechars
ROM:E0EB                 LDA     #0
ROM:E0ED                 STA     CurTextBufferBase ; Trim left of buffer, msg too long
ROM:E0EF                 LDY     #1
ROM:E0F1                 JMP     parsechars
ROM:E0F4 ; ---------------------------------------------------------------------------
ROM:E0F4
ROM:E0F4 specialchar2:
ROM:E0F4                 STA     SpecialChar?
ROM:E0F6                 LDA     #0
ROM:E0F8                 STA     CurTextBufferBase,Y
ROM:E0FB                 INX
ROM:E0FC                 STX     CurCharIndex
ROM:E0FE                 RTS
ROM:E0FF ; ---------------------------------------------------------------------------
ROM:E0FF
ROM:E0FF specialchar1:
ROM:E0FF                 LDA     #$5E ; '^'
ROM:E101                 STA     SpecialChar?
ROM:E103                 LDA     #0
ROM:E105                 STA     CurTextBufferBase,Y
ROM:E108                 RTS
ROM:E108 ; End of function ParseSpecialChars?
ROM:E108
ROM:E109
ROM:E109 ; =============== S U B R O U T I N E =======================================
ROM:E109
ROM:E109
ROM:E109 ParsePercent:
ROM:E109                 LDX     #0
ROM:E10B                 LDY     #0
ROM:E10D                 STY     PercentCharPos
ROM:E10F                 STY     FontIndex
ROM:E111                 SLO     RAMSTART,X      ; RMB1
ROM:E113
ROM:E113 nextchar:
ROM:E113                 LDA     CurTextBufferBase,X
ROM:E115                 BEQ     endcode
ROM:E117                 CMP     #$25 ; '%'
ROM:E119                 BNE     notpercent
ROM:E11B                 STX     PercentCharPos
ROM:E11D                 SAX     RAMSTART,Y      ; SMB1
ROM:E11F
ROM:E11F notpercent:
ROM:E11F                 INX
ROM:E120                 JSR     CheckPrintableChar
ROM:E123                 BCC     nextchar
ROM:E125                 JMP     AbortClear      ; Abort and clear display if non-printable character found
ROM:E128 ; ---------------------------------------------------------------------------
ROM:E128
ROM:E128 endcode:
ROM:E128                 TXA
ROM:E129                 STA     CharLength
ROM:E12B                 BEQ     loc_E160
ROM:E12D                 DEC     CharLength
ROM:E12F
ROM:E12F ComputeTextWidth:
ROM:E12F                 LDX     #0
ROM:E131                 STX     ColumnIndex?
ROM:E133                 STX     CharIndex
ROM:E135
ROM:E135 loc_E135:
ROM:E135                 LDY     CharIndex
ROM:E137                 LDA     CurTextBufferBase,Y
ROM:E13A                 INC     CharIndex
ROM:E13C                 CMP     #0
ROM:E13E                 BEQ     loc_E15B
ROM:E140                 CMP     #$25 ; '%'
ROM:E142                 BNE     loc_E146
ROM:E144                 LDA     #$20 ; ' '      ; Replace % with space
ROM:E146
ROM:E146 loc_E146:
ROM:E146                 JSR     GetGfxTableAddr
ROM:E149                 LDY     #0
ROM:E14B
ROM:E14B loc_E14B:
ROM:E14B                 LDA     (WordVarLow),Y
ROM:E14D                 CMP     #$FF
ROM:E14F                 BEQ     loc_E135
ROM:E151                 CPY     #8
ROM:E153                 BEQ     loc_E135
ROM:E155                 INC     ColumnIndex?
ROM:E157                 INY
ROM:E158                 JMP     loc_E14B
ROM:E15B ; ---------------------------------------------------------------------------
ROM:E15B
ROM:E15B loc_E15B:
ROM:E15B                 LDA     ColumnIndex?
ROM:E15D                 CLC
ROM:E15E                 ADC     CharLength
ROM:E160
ROM:E160 loc_E160:
ROM:E160                 STA     TotalColumnCount
ROM:E162                 LDA     FontIndex
ROM:E164                 BNE     loc_E16D
ROM:E166                 CLC
ROM:E167                 LDA     TotalColumnCount
ROM:E169                 ADC     CharLength
ROM:E16B                 STA     TotalColumnCount
ROM:E16D
ROM:E16D loc_E16D:
ROM:E16D                 JSR     DoClock
ROM:E170                 LDA     TotalColumnCount
ROM:E172                 CMP     #84             ; See if the column count is wider than the display
ROM:E174                 BEQ     columncountok
ROM:E176                 BCC     columncountok
ROM:E178                 LDA     FontIndex
ROM:E17A                 CMP     #4
ROM:E17C                 BEQ     AbortClear      ; Reached smalled font, message is too wide :(
ROM:E17E                 INC     FontIndex       ; Try a smaller font
ROM:E180                 JMP     ComputeTextWidth
ROM:E183 ; ---------------------------------------------------------------------------
ROM:E183
ROM:E183 AbortClear:
ROM:E183                 JSR     ClearDisplay
ROM:E186                 RTS
ROM:E187 ; ---------------------------------------------------------------------------
ROM:E187
ROM:E187 columncountok:
ROM:E187                 LDA     #0
ROM:E189                 STA     ColumnIndex?
ROM:E18B                 SEC
ROM:E18C                 LDA     #84             ; Center text: (84 - column count) / 2
ROM:E18E                 SBC     TotalColumnCount
ROM:E190                 LSR     A
ROM:E191                 STA     PaddingLeft
ROM:E193                 STA     PaddingRight
ROM:E195                 BCC     even            ; Handle odd width to clear sides correctly
ROM:E197                 INC     PaddingLeft
ROM:E199
ROM:E199 even:
ROM:E199                 JSR     DoClock
ROM:E19C                 SHA     $940,Y          ; BBS1
ROM:E19F                 LDA     PaddingLeft
ROM:E1A1                 JSR     ClearNColumns
ROM:E1A4                 LDA     #0
ROM:E1A6                 STA     PaddingLeft
ROM:E1A8                 LDA     #0
ROM:E1AA                 STA     CharIndex
ROM:E1AC
ROM:E1AC printloop:
ROM:E1AC                 LDY     CharIndex
ROM:E1AE                 LDA     CurTextBufferBase,Y
ROM:E1B1                 INC     CharIndex
ROM:E1B3                 CMP     #0
ROM:E1B5                 BEQ     clearright
ROM:E1B7                 CMP     #$25 ; '%'
ROM:E1B9                 BEQ     percent
ROM:E1BB                 JSR     PrintChar
ROM:E1BE                 JMP     printloop
ROM:E1C1 ; ---------------------------------------------------------------------------
ROM:E1C1
ROM:E1C1 percent:
ROM:E1C1                 LDA     PaddingLeft
ROM:E1C3                 JSR     ClearNColumns
ROM:E1C6                 LDA     #0
ROM:E1C8                 STA     PaddingLeft
ROM:E1CA                 LDA     #$20 ; ' '
ROM:E1CC                 JSR     PrintChar
ROM:E1CF                 JMP     printloop
ROM:E1D2 ; ---------------------------------------------------------------------------
ROM:E1D2
ROM:E1D2 clearright:
ROM:E1D2                 LDA     PaddingRight
ROM:E1D4                 JSR     ClearNColumns
ROM:E1D7                 LDA     #0
ROM:E1D9                 STA     PaddingRight
ROM:E1DB                 RTS
ROM:E1DB ; End of function ParsePercent
ROM:E1DB
ROM:E1DC
ROM:E1DC ; =============== S U B R O U T I N E =======================================
ROM:E1DC
ROM:E1DC
ROM:E1DC PrintChar:
ROM:E1DC                 JSR     GetGfxTableAddr
ROM:E1DF                 JSR     PrintGfx
ROM:E1E2                 RTS
ROM:E1E2 ; End of function PrintChar
ROM:E1E2
ROM:E1E3
ROM:E1E3 ; =============== S U B R O U T I N E =======================================
ROM:E1E3
ROM:E1E3
ROM:E1E3 CheckPrintableChar:
ROM:E1E3                 CMP     #$20 ; ' '
ROM:E1E5                 BCC     notprintable
ROM:E1E7                 CMP     #$5D ; ']'
ROM:E1E9                 BEQ     isprintable
ROM:E1EB                 BCC     isprintable
ROM:E1ED
ROM:E1ED notprintable:
ROM:E1ED                 SEC
ROM:E1EE                 RTS
ROM:E1EF ; ---------------------------------------------------------------------------
ROM:E1EF
ROM:E1EF isprintable:
ROM:E1EF                 CLC
ROM:E1F0                 RTS
ROM:E1F0 ; End of function CheckPrintableChar
ROM:E1F0
ROM:E1F1
ROM:E1F1 ; =============== S U B R O U T I N E =======================================
ROM:E1F1
ROM:E1F1
ROM:E1F1 GetGfxTableAddr:
ROM:E1F1                 SEC
ROM:E1F2                 SBC     #$20 ; ' '      ; Charset starts at ' '
ROM:E1F4                 STA     WordVarLow      ; Compute char gfx address (char - $20) * 8
ROM:E1F6                 LDA     #0
ROM:E1F8                 STA     WordVarHigh
ROM:E1FA                 ASL     WordVarLow
ROM:E1FC                 ROL     WordVarHigh
ROM:E1FE                 ASL     WordVarLow
ROM:E200                 ROL     WordVarHigh
ROM:E202                 ASL     WordVarLow
ROM:E204                 ROL     WordVarHigh
ROM:E206                 LDA     FontIndex
ROM:E208                 BNE     fontnot0
ROM:E20A
ROM:E20A font01:
ROM:E20A                 CLC
ROM:E20B                 LDA     #$5F ; '_'      ; Fontset (bold) is at $E45F
ROM:E20D                 ADC     WordVarLow
ROM:E20F                 STA     WordVarLow
ROM:E211                 LDA     #$E4 ; 'õ'
ROM:E213                 ADC     WordVarHigh
ROM:E215                 STA     WordVarHigh
ROM:E217                 RTS
ROM:E218 ; ---------------------------------------------------------------------------
ROM:E218
ROM:E218 fontnot0:
ROM:E218                 CMP     #1
ROM:E21A                 BNE     fontnot01
ROM:E21C                 JMP     font01
ROM:E21F ; ---------------------------------------------------------------------------
ROM:E21F
ROM:E21F fontnot01:
ROM:E21F                 CMP     #2
ROM:E221                 BNE     fontnot012
ROM:E223                 CPY     PercentCharPos
ROM:E225                 BCC     font01
ROM:E227                 JMP     font3
ROM:E22A ; ---------------------------------------------------------------------------
ROM:E22A
ROM:E22A fontnot012:
ROM:E22A                 CMP     #3
ROM:E22C                 BNE     fontnot0123
ROM:E22E
ROM:E22E font3:
ROM:E22E                 CLC
ROM:E22F                 LDA     #$4F ; 'O'      ; Fontset (medium) is at $E64F
ROM:E231                 ADC     WordVarLow
ROM:E233                 STA     WordVarLow
ROM:E235                 LDA     #$E6 ; 'µ'
ROM:E237                 ADC     WordVarHigh
ROM:E239                 STA     WordVarHigh
ROM:E23B                 RTS
ROM:E23C ; ---------------------------------------------------------------------------
ROM:E23C
ROM:E23C fontnot0123:
ROM:E23C                 CLC
ROM:E23D                 LDA     #$3F ; '?'      ; Fontset (small) is at $E83F
ROM:E23F                 ADC     WordVarLow
ROM:E241                 STA     WordVarLow
ROM:E243                 LDA     #$E8 ; 'Þ'
ROM:E245                 ADC     WordVarHigh
ROM:E247                 STA     WordVarHigh
ROM:E249                 RTS
ROM:E249 ; End of function GetGfxTableAddr
ROM:E249
ROM:E24A
ROM:E24A ; =============== S U B R O U T I N E =======================================
ROM:E24A
ROM:E24A
ROM:E24A PrintGfx:
ROM:E24A                 LDY     #0
ROM:E24C
ROM:E24C ReadCharGfx:
ROM:E24C                 LDA     (WordVarLow),Y
ROM:E24E                 CMP     #$FF            ; Early end code
ROM:E250                 BEQ     charend         ; One-column space
ROM:E252                 CPY     #8              ; Column counter, max is 8 per char
ROM:E254                 BEQ     charend         ; One-column space
ROM:E256                 JSR     SetColumnDots
ROM:E259                 INY
ROM:E25A                 JMP     ReadCharGfx
ROM:E25D ; ---------------------------------------------------------------------------
ROM:E25D
ROM:E25D charend:
ROM:E25D                 JSR     ClearColumn     ; One-column space
ROM:E260                 LDA     FontIndex
ROM:E262                 BNE     nosecondspace
ROM:E264                 JSR     ClearColumn
ROM:E267
ROM:E267 nosecondspace:
ROM:E267                 RTS
ROM:E267 ; End of function PrintGfx
ROM:E267
ROM:E268
ROM:E268 ; =============== S U B R O U T I N E =======================================
ROM:E268
ROM:E268
ROM:E268 SetColumnDots:
ROM:E268                 LDX     #1
ROM:E26A                 STX     DotIndex
ROM:E26C                 RLA     byte_2540       ; BBR2
ROM:E26F                 STA     byte_62
ROM:E271                 LDX     ColumnIndex?
ROM:E273                 EOR     $75,X
ROM:E275                 STA     PIXELS
ROM:E277                 LDA     byte_62
ROM:E279                 STA     $75,X
ROM:E27B
ROM:E27B loc_E27B:
ROM:E27B                 LSR     PIXELS
ROM:E27D                 BCS     pixelset
ROM:E27F                 LSR     byte_62
ROM:E281                 JMP     loc_E289
ROM:E284 ; ---------------------------------------------------------------------------
ROM:E284
ROM:E284 pixelset:
ROM:E284                 LSR     byte_62
ROM:E286                 JSR     SetDot
ROM:E289
ROM:E289 loc_E289:
ROM:E289                 INC     DotIndex
ROM:E28B                 LDA     DotIndex
ROM:E28D                 CMP     #8
ROM:E28F                 BNE     loc_E27B
ROM:E291                 INC     ColumnIndex?
ROM:E293                 RTS
ROM:E293 ; End of function SetColumnDots
ROM:E293
ROM:E294 ; ---------------------------------------------------------------------------
ROM:E294                 LDX     ColumnIndex?
ROM:E296                 STA     $75,X
ROM:E298                 LDX     #7              ; Dot count in one column
ROM:E29A
ROM:E29A loc_E29A:
ROM:E29A                 LSR     A
ROM:E29B                 JSR     SetDot
ROM:E29E                 INC     DotIndex
ROM:E2A0                 DEX
ROM:E2A1                 BNE     loc_E29A
ROM:E2A3                 INC     ColumnIndex?
ROM:E2A5                 RTS
ROM:E2A6
ROM:E2A6 ; =============== S U B R O U T I N E =======================================
ROM:E2A6
ROM:E2A6
ROM:E2A6 SetDot:
ROM:E2A6                 PHA
ROM:E2A7                 TYA
ROM:E2A8                 PHA
ROM:E2A9                 LDA     DotIndex        ; Output to port B
ROM:E2AB                 STA     PORTB
ROM:E2AD                 LDY     ColumnIndex?
ROM:E2AF                 LDA     DotLineTable?,Y
ROM:E2B2                 STA     PORTD           ; Output to port D
ROM:E2B4                 BCC     pixelclear      ; RMB6
ROM:E2B6                 ISB     PORTB           ; SMB6
ROM:E2B8                 JMP     pixelset
ROM:E2BB ; ---------------------------------------------------------------------------
ROM:E2BB
ROM:E2BB pixelclear:
ROM:E2BB                 RRA     PORTB           ; RMB6
ROM:E2BD
ROM:E2BD pixelset:
ROM:E2BD                 LDY     #10
ROM:E2BF
ROM:E2BF wait:
ROM:E2BF                 DEY
ROM:E2C0                 BNE     wait
ROM:E2C2                 ISB     1,X
ROM:E2C4                 JSR     WaitAndClock
ROM:E2C7                 RRA     1,X
ROM:E2C9                 LDY     #30
ROM:E2CB
ROM:E2CB waitmore:
ROM:E2CB                 DEY
ROM:E2CC                 BNE     waitmore
ROM:E2CE                 LDA     #0
ROM:E2D0                 STA     PORTB
ROM:E2D2                 STA     PORTD
ROM:E2D4                 PLA
ROM:E2D5                 TAY
ROM:E2D6                 PLA
ROM:E2D7                 RTS
ROM:E2D7 ; End of function SetDot
ROM:E2D7
ROM:E2D8
ROM:E2D8 ; =============== S U B R O U T I N E =======================================
ROM:E2D8
ROM:E2D8
ROM:E2D8 ClearColumn:
ROM:E2D8                 LDA     #0
ROM:E2DA                 JSR     SetColumnDots
ROM:E2DD                 RTS
ROM:E2DD ; End of function ClearColumn
ROM:E2DD
ROM:E2DE
ROM:E2DE ; =============== S U B R O U T I N E =======================================
ROM:E2DE
ROM:E2DE
ROM:E2DE ClearDisplay:
ROM:E2DE                 LDA     #0
ROM:E2E0                 STA     ColumnIndex?
ROM:E2E2                 LDA     #84
ROM:E2E4                 JSR     ClearNColumns
ROM:E2E7                 RTS
ROM:E2E7 ; End of function ClearDisplay
ROM:E2E7
ROM:E2E8
ROM:E2E8 ; =============== S U B R O U T I N E =======================================
ROM:E2E8
ROM:E2E8
ROM:E2E8 ClearNColumns:
ROM:E2E8                 STA     WordVarLow
ROM:E2EA
ROM:E2EA lp:
ROM:E2EA                 LDA     WordVarLow
ROM:E2EC                 BEQ     done
ROM:E2EE                 JSR     ClearColumn
ROM:E2F1                 DEC     WordVarLow
ROM:E2F3                 JMP     lp
ROM:E2F6 ; ---------------------------------------------------------------------------
ROM:E2F6
ROM:E2F6 done:
ROM:E2F6                 RTS
ROM:E2F6 ; End of function ClearNColumns
ROM:E2F6
ROM:E2F7
ROM:E2F7 ; =============== S U B R O U T I N E =======================================
ROM:E2F7
ROM:E2F7
ROM:E2F7 TxErrorCode:
ROM:E2F7                 RRA     IRQCFG
ROM:E2F9                 LDA     #$FF            ; RMB6 - Clear RX IRQ flag
ROM:E2FB                 JSR     WriteSerialByte
ROM:E2FE                 LDA     #1
ROM:E300                 JSR     WriteSerialByte
ROM:E303                 LDA     #1
ROM:E305                 JSR     WriteSerialByte
ROM:E308                 SAX     $D41            ; BBS0 $41
ROM:E30B                 LDA     #6
ROM:E30D                 JSR     WriteSerialByte
ROM:E310                 LDA     #6
ROM:E312                 JSR     WriteSerialByte
ROM:E315                 JMP     code6           ; RMB0
ROM:E318 ; ---------------------------------------------------------------------------
ROM:E318                 LDA     #$15
ROM:E31A                 JSR     WriteSerialByte
ROM:E31D                 LDA     #$15
ROM:E31F                 JSR     WriteSerialByte
ROM:E322
ROM:E322 code6:
ROM:E322                 SLO     FLAGS           ; RMB0
ROM:E324                 ISB     IRQCFG          ; SMB6
ROM:E326                 RRA     $41,X           ; RMB7 $41
ROM:E328                 RTS
ROM:E328 ; End of function TxErrorCode
ROM:E328
ROM:E329
ROM:E329 ; =============== S U B R O U T I N E =======================================
ROM:E329
ROM:E329
ROM:E329 WriteSerialByte:
ROM:E329                 RRA     byte_FD16
ROM:E32C                 STA     SERIALDATA      ; BBR6 $16 - Wait for tx reg empty then send A
ROM:E32E                 RTS
ROM:E32E ; End of function WriteSerialByte
ROM:E32E
ROM:E32F ; ---------------------------------------------------------------------------
ROM:E32F
ROM:E32F IRQ:
ROM:E32F                 PHA                     ; IRQ: Received byte !
ROM:E330                 TXA
ROM:E331                 PHA
ROM:E332                 TYA
ROM:E333                 PHA
ROM:E334                 SAX     $516            ; BBS0 $16 - See if RCRV full in status reg
ROM:E337                 LDA     SERIALDATA      ; Not full: clear received byte and return
ROM:E339                 JMP     IRQRet
ROM:E33C ; ---------------------------------------------------------------------------
ROM:E33C                 LDA     SERIALDATA      ; Full: read received byte
ROM:E33E                 DCP     $1640           ; BBS4 $40 - Return if true
ROM:E341                 TAY
ROM:E342                 LDA     CurrentRXState  ; Jump table, table=JTRx index=CurrentRXState
ROM:E344                 AND     #7
ROM:E346                 ASL     A
ROM:E347                 TAX
ROM:E348                 LDA     JTRx,X
ROM:E34B                 STA     JumpLSB
ROM:E34D                 INX
ROM:E34E                 LDA     JTRx,X
ROM:E351                 STA     JumpMSB
ROM:E353                 TYA
ROM:E354                 JMP     (JumpLSB)
ROM:E357 ; ---------------------------------------------------------------------------
ROM:E357
ROM:E357 IRQRet:
ROM:E357                 PLA
ROM:E358                 TAY
ROM:E359                 PLA
ROM:E35A                 TAX
ROM:E35B                 PLA
ROM:E35C                 RTI
ROM:E35C ; ---------------------------------------------------------------------------
ROM:E35D JTRx:           .WORD STATE0            ; Wants $FF
ROM:E35F                 .WORD STATE1            ; Wants "A"
ROM:E361                 .WORD STATE2            ; Abort if message length is zero
ROM:E363                 .WORD STATE3            ; Store char in buffer
ROM:E365                 .WORD STATE4            ; Reset state
ROM:E367                 .WORD STATE0            ; Wants $FF
ROM:E369                 .WORD STATE0            ; Wants $FF
ROM:E36B                 .WORD STATE0            ; Wants $FF
ROM:E36D ; ---------------------------------------------------------------------------
ROM:E36D
ROM:E36D STATE0:
ROM:E36D                 CMP     #$FF            ; Wants $FF
ROM:E36F                 BEQ     equalsFF
ROM:E371                 LDX     #0              ; ...or aborts
ROM:E373                 STX     CurrentRXState
ROM:E375                 JMP     IRQRet
ROM:E378 ; ---------------------------------------------------------------------------
ROM:E378
ROM:E378 equalsFF:
ROM:E378                 LDX     #1
ROM:E37A                 STX     CurrentRXState  ; Next state
ROM:E37C                 LDX     #0
ROM:E37E                 STX     MessagePtr      ; Getting ready
ROM:E380                 STX     RxChecksum
ROM:E382                 JMP     IRQRet
ROM:E385 ; ---------------------------------------------------------------------------
ROM:E385
ROM:E385 STATE1:
ROM:E385                 CMP     #'A'            ; Wants "A"
ROM:E387                 BEQ     EqualsA         ; Update checksum
ROM:E389                 LDX     #0              ; ...or aborts
ROM:E38B                 STX     CurrentRXState
ROM:E38D                 JMP     STATE0          ; Wants $FF
ROM:E390 ; ---------------------------------------------------------------------------
ROM:E390
ROM:E390 EqualsA:
ROM:E390                 EOR     RxChecksum      ; Update checksum
ROM:E392                 STA     RxChecksum
ROM:E394                 LDA     #2              ; Next state
ROM:E396                 STA     CurrentRXState
ROM:E398                 JMP     IRQRet
ROM:E39B ; ---------------------------------------------------------------------------
ROM:E39B
ROM:E39B STATE2:
ROM:E39B                 CMP     #0              ; Abort if message length is zero
ROM:E39D                 BEQ     zerolength      ; Abort
ROM:E39F                 STA     MessageLength
ROM:E3A1                 EOR     RxChecksum      ; Update checksum
ROM:E3A3                 STA     RxChecksum
ROM:E3A5                 LDX     #3
ROM:E3A7                 STX     CurrentRXState  ; Next state
ROM:E3A9                 JMP     IRQRet
ROM:E3AC ; ---------------------------------------------------------------------------
ROM:E3AC
ROM:E3AC zerolength:
ROM:E3AC                 LDX     #0              ; Abort
ROM:E3AE                 STX     CurrentRXState
ROM:E3B0                 JMP     IRQRet
ROM:E3B3 ; ---------------------------------------------------------------------------
ROM:E3B3
ROM:E3B3 STATE3:
ROM:E3B3                 LDX     MessagePtr      ; Store char in buffer
ROM:E3B5                 STA     RxMsgBufferBase,X
ROM:E3B8                 EOR     RxChecksum      ; Update checksum
ROM:E3BA                 STA     RxChecksum
ROM:E3BC                 INX
ROM:E3BD                 STX     MessagePtr
ROM:E3BF                 DEC     MessageLength
ROM:E3C1                 BEQ     MsgRxEnd        ; Buffer filled ?
ROM:E3C3                 JMP     IRQRet
ROM:E3C6 ; ---------------------------------------------------------------------------
ROM:E3C6
ROM:E3C6 MsgRxEnd:
ROM:E3C6                 LDX     MessagePtr
ROM:E3C8                 LDA     #0
ROM:E3CA                 STA     RxMsgBufferBase,X ; Terminate with 00
ROM:E3CD                 LDA     #4
ROM:E3CF                 STA     CurrentRXState  ; Next state
ROM:E3D1                 JMP     IRQRet
ROM:E3D4 ; ---------------------------------------------------------------------------
ROM:E3D4
ROM:E3D4 STATE4:
ROM:E3D4                 LDX     #0              ; Reset state
ROM:E3D6                 STX     CurrentRXState
ROM:E3D8                 CMP     RxChecksum      ; Compare checksum
ROM:E3DA                 BEQ     checksumOK
ROM:E3DC                 SAX     FLAGS           ; SMB0 - Set checksum error flag ?
ROM:E3DE                 ISB     FLAGS,X         ; SMB7
ROM:E3E0                 JMP     IRQRet
ROM:E3E3 ; ---------------------------------------------------------------------------
ROM:E3E3
ROM:E3E3 checksumOK:
ROM:E3E3                 LDX     #0
ROM:E3E5                 SLO     FLAGS           ; RMB0 $41
ROM:E3E7                 ISB     FLAGS,X         ; SMB7 $41
ROM:E3E9
ROM:E3E9 checkdiff:
ROM:E3E9                 LDA     RxMsgBufferBase,X
ROM:E3EC                 BEQ     loc_E3FC        ; End char ?
ROM:E3EE                 CMP     CurMsgBufferBase,X
ROM:E3F1                 BNE     MsgIsDifferent  ; SMB4
ROM:E3F3                 INX
ROM:E3F4                 JMP     checkdiff
ROM:E3F7 ; ---------------------------------------------------------------------------
ROM:E3F7
ROM:E3F7 MsgIsDifferent:
ROM:E3F7                 DCP     RAMSTART        ; SMB4
ROM:E3F9                 JMP     IRQRet
ROM:E3FC ; ---------------------------------------------------------------------------
ROM:E3FC
ROM:E3FC loc_E3FC:
ROM:E3FC                 CMP     CurMsgBufferBase,X
ROM:E3FF                 BNE     MsgIsDifferent  ; SMB4
ROM:E401                 JMP     IRQRet
ROM:E401 ; ---------------------------------------------------------------------------
ROM:E404 DotLineTable?:  .BYTE 1
ROM:E405                 .BYTE 2
ROM:E406                 .BYTE 3
ROM:E407                 .BYTE 4
ROM:E408                 .BYTE 5
ROM:E409                 .BYTE 6
ROM:E40A                 .BYTE 7
ROM:E40B                 .BYTE 9
ROM:E40C                 .BYTE $A
ROM:E40D                 .BYTE $B
ROM:E40E                 .BYTE $C
ROM:E40F                 .BYTE $D
ROM:E410                 .BYTE $E
ROM:E411                 .BYTE $F
ROM:E412                 .BYTE $11
ROM:E413                 .BYTE $12
ROM:E414                 .BYTE $13
ROM:E415                 .BYTE $14
ROM:E416                 .BYTE $15
ROM:E417                 .BYTE $16
ROM:E418                 .BYTE $17
ROM:E419                 .BYTE $19
ROM:E41A                 .BYTE $1A
ROM:E41B                 .BYTE $1B
ROM:E41C                 .BYTE $1C
ROM:E41D                 .BYTE $1D
ROM:E41E                 .BYTE $1E
ROM:E41F                 .BYTE $1F
ROM:E420                 .BYTE $21 ; !
ROM:E421                 .BYTE $22 ; "
ROM:E422                 .BYTE $23 ; #
ROM:E423                 .BYTE $24 ; $
ROM:E424                 .BYTE $25 ; %
ROM:E425                 .BYTE $26 ; &
ROM:E426                 .BYTE $27 ; '
ROM:E427                 .BYTE $29 ; )
ROM:E428                 .BYTE $2A ; *
ROM:E429                 .BYTE $2B ; +
ROM:E42A                 .BYTE $2C ; ,
ROM:E42B                 .BYTE $2D ; -
ROM:E42C                 .BYTE $2E ; .
ROM:E42D                 .BYTE $2F ; /
ROM:E42E                 .BYTE $31 ; 1
ROM:E42F                 .BYTE $32 ; 2
ROM:E430                 .BYTE $33 ; 3
ROM:E431                 .BYTE $34 ; 4
ROM:E432                 .BYTE $35 ; 5
ROM:E433                 .BYTE $36 ; 6
ROM:E434                 .BYTE $37 ; 7
ROM:E435                 .BYTE $39 ; 9
ROM:E436                 .BYTE $3A ; :
ROM:E437                 .BYTE $3B ; ;
ROM:E438                 .BYTE $3C ; <
ROM:E439                 .BYTE $3D ; =
ROM:E43A                 .BYTE $3E ; >
ROM:E43B                 .BYTE $3F ; ?
ROM:E43C                 .BYTE $41 ; A
ROM:E43D                 .BYTE $42 ; B
ROM:E43E                 .BYTE $43 ; C
ROM:E43F                 .BYTE $44 ; D
ROM:E440                 .BYTE $45 ; E
ROM:E441                 .BYTE $46 ; F
ROM:E442                 .BYTE $47 ; G
ROM:E443                 .BYTE $49 ; I
ROM:E444                 .BYTE $4A ; J
ROM:E445                 .BYTE $4B ; K
ROM:E446                 .BYTE $4C ; L
ROM:E447                 .BYTE $4D ; M
ROM:E448                 .BYTE $4E ; N
ROM:E449                 .BYTE $4F ; O
ROM:E44A                 .BYTE $51 ; Q
ROM:E44B                 .BYTE $52 ; R
ROM:E44C                 .BYTE $53 ; S
ROM:E44D                 .BYTE $54 ; T
ROM:E44E                 .BYTE $55 ; U
ROM:E44F                 .BYTE $56 ; V
ROM:E450                 .BYTE $57 ; W
ROM:E451                 .BYTE $59 ; Y
ROM:E452                 .BYTE $5A ; Z
ROM:E453                 .BYTE $5B ; [
ROM:E454                 .BYTE $5C ; \
ROM:E455                 .BYTE $5D ; ]
ROM:E456                 .BYTE $5E ; ^
ROM:E457                 .BYTE $5F ; _
ROM:E458                 .BYTE $60 ; `
ROM:E459                 .BYTE $60 ; `
ROM:E45A                 .BYTE $60 ; `
ROM:E45B                 .BYTE $60 ; `
ROM:E45C                 .BYTE $60 ; `
ROM:E45D                 .BYTE $60 ; `
ROM:E45E                 .BYTE $60 ; `
ROM:E45F FontBig
ROM:E64F FontMedium
ROM:E83F FontSmall
ROM:FFFA                 .WORD RESET
ROM:FFFC                 .WORD RESET             ; Reset vector
ROM:FFFE                 .WORD IRQ               ; IRQ vector
ROM:FFFF ; end of 'ROM'
