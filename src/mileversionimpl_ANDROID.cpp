#include "mileversion/mileversion.h"
#include "mileversion/mileversionimpl_ANDROID.h"
#include "mileversion/exceptions.h"

#include <elfio/elfio.hpp>
#include <cstdio>
#include <cstring>

namespace mileversion {

mileversionimpl::mileversionimpl(const std:: string &filename) : 
	_filename(filename), _haveinfo(false)
{
	// Create ELFIO reader
	ELFIO::elfio reader;
	
	// Load the ELF file
	if (!reader.load(filename)) {
		// Failed to load file
		return;
	}
	
	// Iterate through sections to find symbol table
	ELFIO:: Elf_Half sec_num = reader.sections.size();
	for (ELFIO:: Elf_Half i = 0; i < sec_num; ++i) {
		ELFIO::section* psec = reader. sections[i];
		
		// Check if this is a symbol table section
		if (psec->get_type() == ELFIO::SHT_SYMTAB) {
			const ELFIO::symbol_section_accessor symbols(reader, psec);
			
			// Iterate through all symbols
			for (unsigned int j = 0; j < symbols.get_symbols_num(); ++j) {
				std::string name;
				ELFIO::Elf64_Addr value;
				ELFIO::Elf_Xword size;
				unsigned char bind;
				unsigned char type;
				ELFIO::Elf_Half section_index;
				unsigned char other;
				
				// Read symbol properties
				symbols.get_symbol(j, name, value, size, bind, type, section_index, other);
				
				// Look for our version string symbol
				if (name.find(MILEVERSION_VERSION_STR) == 0) {
					// Found version symbol, extract version numbers
					const char* versionstart = name.c_str() + strlen(MILEVERSION_VERSION_STR);
					int mh, ml, nh, nl;
					
					if (sscanf(versionstart, "%d_%d_%d_%d", &mh, &ml, &nh, &nl) == 4) {
						_haveinfo = true;
						char vinfo[50];
						sprintf(vinfo, "%d.%d.%d. %d", mh, ml, nh, nl);
						_fileversion = vinfo;
						return;
					}
				}
			}
		}
	}
}

mileversionimpl::~mileversionimpl()
{
}

bool mileversionimpl:: haveInfo()
{
	return _haveinfo;
}

const std::string &mileversionimpl::fileVersion()
{
	return _fileversion;
}

};