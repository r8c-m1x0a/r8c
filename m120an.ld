/*======================================================================/
/	@file
/	@brief    R8C(Tiny)/M110AN, R8C(Tiny)/M120AN Link Loader Script @n
/	Flash-ROM and RAM extends version @n
/   Flash-ROM: 2048(0xF800) ---> 32768(start: 0x8000) bytes @n
/   RAM:        256(0x0400) --->  1280(start: 0x0300) bytes
/   @author 平松邦仁 (hira@rvf-rc45.net)
/   @copyright	Copyright (C) 2015, 2017 Kunihito Hiramatsu @n
/				Released under the MIT license @n
/				https://github.com/hirakuni45/RX/blob/master/LICENSE
/
/   I/Oを直接アクセス可能なように定義IOを追加しています。(S.Hanai ruimo.uno@gmail.com)
/======================================================================*/

/* Default linker script, for normal executables */
OUTPUT_FORMAT("elf32-m32c", "elf32-m32c",
	      "elf32-m32c")
OUTPUT_ARCH(m32c)
ENTRY(_start)
INPUT(-lm32cgloss)
/* Do we need any of these for elf?
   __DYNAMIC = 0;    */
MEMORY {
	IO  (w)  : ORIGIN = 0x00010, LENGTH = 0x001F0
	RAM (w)  : ORIGIN = 0x00300, LENGTH = 0x00400
	ROM (r)  : ORIGIN = 0x08000, LENGTH = 0x07ED8
	EXT (r)  : ORIGIN = 0x10000, LENGTH = 0x08000
	VVEC (r) : ORIGIN = 0x0FED8, LENGTH = 256
	FVEC (r) : ORIGIN = 0x0FFD8, LENGTH = 40
}
SECTIONS
{
		_usp_init = 0x07C0;
		_isp_init = 0x0800;

  /* There are three cases we care about: First, RW data that must be
     in the low 64k.  This will always be copied from ROM.  Second, RO
     data that must be in the low 64k.  This may be copied from ROM if
     the ROM is above 64k.  Third, anything that does not need to be
     in the first 64k.  Chips normally only have two memory regions;
     low ram and either high or low rom.  We map the low rom needs
     into one of the actual regions.  */

  /* .text goes first so the rom image of ram data will follow it.  */
  .text           :
  {
    *(.text .stub .text.* .gnu.linkonce.t.*)
    KEEP (*(.text.*personality*))
    /* .gnu.warning sections are handled specially by elf32.em.  */
    *(.gnu.warning)
    *(.interp .hash .dynsym .dynstr .gnu.version*)
    PROVIDE (__etext = .);
    PROVIDE (_etext = .);
    PROVIDE (etext = .);
    . = ALIGN(2);
  } > ROM =0

  .exttext   :
  {
    *(.exttext .stub .exttext.* .gnu.linkonce.t.*)
    KEEP (*(.exttext.*personality*))
    /* .gnu.warning sections are handled specially by elf32.em.  */
    *(.gnu.warning)
    *(.interp .hash .dynsym .dynstr .gnu.version*)
  } > EXT =0


  /* rodata will either be part of data, or will be in low rom.  So we
     might be spanning it, or we might not.  This lets us include it
     in our calculations when appropriate.  */

  .rodata : {
    . = ALIGN(2);
    *(.plt)
    KEEP (*(.init))
    KEEP (*(.fini))
    *(.rodata .rodata.* .gnu.linkonce.r.*)
    *(.rodata1)
    *(.eh_frame_hdr)
    KEEP (*(.eh_frame))
    KEEP (*(.gcc_except_table)) *(.gcc_except_table.*)
    . = ALIGN(2);
    PROVIDE(__romdatastart = .); /* IF_ROROM */
  } > ROM

  PROVIDE( __datainternal = ABSOLUTE(LOADADDR(.data)));

  .data : {
    . = ALIGN(32 / 8);
    PROVIDE (__datastart = .); /* IF_ROROM */
    PROVIDE (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE (__preinit_array_end = .);
    PROVIDE (__init_array_start = .);
    KEEP (*(.init_array))
    PROVIDE (__init_array_end = .);
    PROVIDE (__fini_array_start = .);
    KEEP (*(.fini_array))
    PROVIDE (__fini_array_end = .);

    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin*.o(.ctors))
    /* We don't want to include the .ctor section from
       from the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend*.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))

    KEEP (*crtbegin*.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend*.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))

    KEEP (*(.jcr))
    *(.data.rel.ro.local) *(.data.rel.ro*)
    *(.dynamic)

    *(.data .data.* .gnu.linkonce.d.*)
    KEEP (*(.gnu.linkonce.d.*personality*))
    SORT(CONSTRUCTORS)
    *(.data1)
    *(.got.plt) *(.got)
    PROVIDE (__var_vect_start = .);
    *(.var_vects)

    . = ALIGN(2);
    _edata = .;
    PROVIDE (edata = .);
    PROVIDE (__dataend = .);
  } > RAM AT>ROM

  /* Note that __romdatacopysize may be ZERO for the simulator, which
     knows how to intialize RAM directly.  It should ONLY be used for
     copying data from ROM to RAM; if you need to know the size of the
     data section, subtract the end symbol from the start symbol.  */
  /* Note that crt0 assumes this is even; all the start/stop symbols
     are also assumed word-aligned.  */
  PROVIDE (__romdatacopysize =SIZEOF(.data));

   .io (NOLOAD) : {
      *(.io);
   } > IO

  .bss : {
    . = ALIGN(2);
    PROVIDE (__bssstart = .);
    *(.dynbss)
    *(.bss .bss.* .gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(2);
    PROVIDE (__bssend = .);
    _end = .;
    PROVIDE (end = .);
  } > RAM
  PROVIDE (__bsssize = SIZEOF(.bss));

  .vvec : {
    KEEP( *(.vvec) )
  } > VVEC

  .fvec : {
    KEEP( *(.fvec) )
  } > FVEC

  /* The rest are all not normally part of the runtime image.  */

  /* Stabs debugging sections.  */
  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .stab.excl     0 : { *(.stab.excl) }
  .stab.exclstr  0 : { *(.stab.exclstr) }
  .stab.index    0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment       0 : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
  /DISCARD/ : { *(.note.GNU-stack) }
}
