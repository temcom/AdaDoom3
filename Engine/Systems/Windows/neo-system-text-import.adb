--
--
--
--
--
--
--
-- After first booting up the clipboard is empty and if Get_Clipboard is called a system call
-- failure is raised when instead a null string should be returned.
--
--
--
--
--
--
--
with
  Interfaces,
  Interfaces.C,
  Ada.Unchecked_Conversion,
  Neo.Link.Windows;
use
  Interfaces,
  Interfaces.C,
  Neo.Link.Windows;
separate(Neo.System.Text)
package body Import
  is
  ------------------
  -- Get_Language --
  ------------------
    function Get_Language
      return Enumerated_Language
      is
      begin
        case Get_System_Default_Language is
          when LANGUAGE_ARABIC =>
            return Arabic_Language;
          when LANGUAGE_BASQUE =>
            return Basque_Language;
          when LANGUAGE_CATALAN =>
            return Catalan_Language;
          when LANGUAGE_CHINESE_SIMPLIFIED =>
            return Simplified_Chinese_Language;
          when LANGUAGE_CHINESE_TRADITIONAL =>
            return Traditional_Chinese_Language;
          when LANGUAGE_CZECH =>
            return Czech_Language;
          when LANGUAGE_DANISH =>
            return Danish_Language;
          when LANGUAGE_DUTCH =>
            return Dutch_Language;
          when LANGUAGE_ENGLISH =>
            return English_Language;
          when LANGUAGE_FINNISH =>
            return Finnish_Langauge;
          when LANGUAGE_FRENCH =>
            return French_Langauge;
          when LANGUAGE_GERMAN =>
            return German_Language;
          when LANGUAGE_GREEK =>
            return Greek_Language;
          when LANGUAGE_HEBREW =>
            return Hebrew_Language;
          when LANGUAGE_HUNGARIAN =>
            return Hungarian_Language;
          when LANGUAGE_ITALIAN =>
            return Italian_Language;
          when LANGUAGE_JAPANESE =>
            return Japanese_Language;
          when LANGUAGE_KOREAN =>
            return Korean_Language;
          when LANGUAGE_NORWEGIAN =>
            return Norwegian_Language;
          when LANGUAGE_POLISH =>
            return Polish_Language;
          when LANGUAGE_PORTUGUESE =>
            return Portuguese_Language;
          when LANGUAGE_PORTUGUESE_BRAZIL =>
            return Brazilian_Portuguese_Language;
          when LANGUAGE_RUSSIAN =>
            return Russian_Language;
          when LANGUAGE_SLOVAKIAN =>
            return Slovakian_Language;
          when LANGUAGE_SLOVENIAN =>
            return Slovenian_Language;
          when LANGUAGE_SPANISH =>
            return Spanish_Language;
          when LANGUAGE_SWEDISH =>
            return Swedish_Language;
          when LANGUAGE_TURKISH =>
            return Turkish_Language;
          when others =>
            return English_Language;
        end case;
      end Get_Language;
  -------------------
  -- Set_Clipboard --
  -------------------
    procedure Set_Clipboard(
      Text : in String_2)
      is
      type Array_Text
        is array(Text'first..Text'last + 1)
        of Character_2_C;
      type Access_Array_Text
        is access all Array_Text;
      function To_Unchecked_Access_Array_Text
        is new Ada.Unchecked_Conversion(Address, Access_Array_Text);
      Data     : Address           := NULL_ADDRESS;
      Accessor : Access_Array_Text := null;
      begin
        Data :=
	  Global_Allocate(
	    Flags => MEMORY_MOVEABLE or MEMORY_DYNAMIC_DATA_EXCHANGE_SHARE,
	    Bytes => Array_Text'size / Byte'size);
        if Data = NULL_ADDRESS then
          raise Call_Failure;
        end if;
        Accessor := To_Unchecked_Access_Array_Text(Global_Lock(Data));
        if Accessor = null then
          raise Call_Failure;
        end if;
        Accessor(Accessor.All'last) := NULL_CHARACTER_2_C;
        for I in Text'range loop
          Accessor(I) := Character_2_C'val(Character_2'pos(Text(I)));
        end loop;
        if Global_Unlock(Data) /= 0 then
          raise Call_Failure;
        end if;
        if Open_Clipboard(NULL_ADDRESS) = FAILED and then Global_Free(Data) /= NULL_ADDRESS then
          raise Call_Failure;
        end if;
        if Empty_Clipboard = FAILED then
          raise Call_Failure;
        end if;
        if Set_Clipboard_Data(CLIPBOARD_UNICODE_TEXT, Data) = NULL_ADDRESS then
          raise Call_Failure;
        end if;
        if Close_Clipboard = FAILED then
          raise Call_Failure;
        end if;
      end Set_Clipboard;
  -------------------
  -- Get_Clipboard --
  -------------------
    function Get_Clipboard
      return String_2
      is
      Data     : Address                       := NULL_ADDRESS;
      Accessor : Access_Constant_Character_2_C := null;
      begin
        if Open_Clipboard(NULL_ADDRESS) = FAILED then
          raise Call_Failure;
        end if;
        Data := Get_Clipboard_Data(CLIPBOARD_UNICODE_TEXT);
        if Data = NULL_ADDRESS then
          raise Call_Failure;
        end if;
        Accessor := To_Unchecked_Access_Constant_Character_2_C(Global_Lock(Data));
        if Accessor = null then
          raise Call_Failure;
        end if;
        ---------------
        Compose_Result:
        ---------------
          declare
          Result : String_2 := To_String_2(Accessor);
          begin
            if Global_Unlock(Data) /= 0 then
              null;--raise Call_Failure; Why does this fail???
            end if;
            if Close_Clipboard = FAILED then
              raise Call_Failure;
            end if;
            return Result;
          end Compose_Result;
      end Get_Clipboard;
  end Import;