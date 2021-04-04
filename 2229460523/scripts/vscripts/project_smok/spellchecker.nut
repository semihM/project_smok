/***************\
* SPELL CHECKER *
\***************/
::SpellChecker <- {}

/* @authors rhino
 *
 * @description Calculate the cost of changing from a word to another
 *
 * @param source <string>: Source(misspelled) word
 * @param target <string>: Target(possible match) word
 * 
 * @return Levenshtein distance of target word to source
 */
::SpellChecker.LevenshteinDist <- function(source, target)
{
	function min(x,y,z)
	{
		return x<=y ? (x<=z ? x : z) 
					: (y<=z ? y : z)
	}

	local dist = {}
	local m = source.len()
	local n = target.len()

	for(local i=0;i<=m;i++)
	{
		dist[i] <- {}
		for(local j=0;j<=n;j++)
		{
			dist[i][j] <- 0
		}
	}

	for(local i=1;i<=m;i++)
	{
		dist[i][0] <- i
	}
	for(local j=1;j<=n;j++)
	{
		dist[0][j] <- j
	}

	for(local j=1;j<=n;j++)
	{
		for(local i=1;i<=m;i++)
		{
			local cost = 0
			if(source[i-1] != target[j-1])
				cost = 1
			dist[i][j] = min(dist[i-1][j] + 1, dist[i][j-1] + 1, dist[i-1][j-1] + cost)
		}
	}

	return dist[m][n]
}

/******************\
* Levenshtein Class *
\******************/
/* @authors rhino
 *
 * @description Create a new Levenshtein instance with a set of maximum search distance, display amount and word category 
 *
 * @param [maxdist <integer> = SCL_DEF_MAXDIST]: Maximum valid distance of target word to source word
 * @param [maxdisp <integer> = SCL_DEF_MAXDISP]: Maximum amount of words to display while printing
 * @param [typ <string> = "command"]: Type of words used. This is used while printing "Unknown @typ: unknown_word."
 * 
 * @return A new instance of ::SpellChecker.Levenshtein
 */
class ::SpellChecker.Levenshtein
{
    constructor(maxdist=SCL_DEF_MAXDIST,maxdisp=SCL_DEF_MAXDISP,typ="command")
    {   
        _maxdist = maxdist
        _maxdisp = maxdisp
		_typ = typ
    }

    function _type()
    {
        return "project_smok_SpellCheck_Levenshtein"
    }

    _maxdist = null
    _maxdisp = null
	_typ = null
}


// TO-DO: Cache checked words
// TO-DO: Find a way around squirrel cancelling the query for longer tables
/* @authors rhino
 *
 * @description Get the distances of given word to keys of given table using a filter on keys
 *
 * @param word <string>: Word to use as source
 * @param lookuptbl <table>: Lookup table with target words as keys, uses maximum of SCL_LOOKUP_LIMIT amount of keys
 * @param [lookup_filter <function> = @(key) key]: Filter function to pass lookup table keys before calculations
 * 
 * @return if there were any matches with <= self._maxdist distance: table (distance <integer>: words <list>) with maximum SCL_LOOKUP_LIMIT total words;
 						otherwise: table = { "-1" : best_match_distance, best_match_distance : closest_match }   
 */
function SpellChecker::Levenshtein::GetDistTable(word, lookuptbl, lookup_filter = @(key) key)
{
	local result = {}
	local backup = {}
	local limit = getconsttable()["SCL_LOOKUP_LIMIT"]

	// To prevent query to be cancelled
	local maxstartindex = lookuptbl.len() > limit ? lookuptbl.len() - limit : 0
	local startidx = RandomInt(0,maxstartindex)
	local checks = 0

	foreach(w,val in lookuptbl)
	{	
		if(checks < startidx)	// Offset starting index for longer tables
		{
			startidx -= 1
			continue;
		}

		if(checks >= limit)
			break;
		
		local dist = ::SpellChecker.LevenshteinDist(word,lookup_filter(w))
		checks += 1;

		if(dist <= _maxdist)
		{
			if(dist in result)
				result[dist].append(w)
			else
				result[dist] <- [w]
		}
		else
		{
			if(backup.len() == 0)
			{
				backup[-1] <- dist
				backup[dist] <- w
			}
			else
			{
				foreach(d,ws in backup)
				{
					if(d > dist)
					{
						backup[-1] <- dist
						backup[dist] <- w
						delete backup[d]
						break;
					}
				}
			}
		}
	}

	if(result.len() == 0 && backup.len() != 0)
	{
		return backup;
	}
	return result;
}

/* @authors rhino
 *
 * @description Get the best self._maxdisp amount matches or the best match of a word using a lookup table keys filtered
 *
 * @param word <string>: Word to use as source
 * @param lookuptbl <table>: Lookup table with target words as keys, uses maximum of SCL_LOOKUP_LIMIT amount of keys
 * @param [lookup_filter <function> = @(key) key]: Filter function to pass lookup table keys before calculations
 * 
 * @return if no valid matches was found(backup was used) : table { "-1" : best_match_distance, best_match_distance : closest_match };
 *							; otherwise: table with self._maxdisp entries {"1" : best_match, "2": second_best, "3": third_best, ...}
 */
function SpellChecker::Levenshtein::GetBestMatches(word, lookuptbl, lookup_filter = @(key) key)
{	
	local matches = GetDistTable(word,lookuptbl,lookup_filter)
	if(matches.len() == 0 || (-1 in matches))
	{
		return matches;
	}
	else
	{	
		local tbl = {}
		local matchesleft = _maxdisp
		local m = 1;

		for(local dist=1;dist<=_maxdist;dist++)
		{
			if(matchesleft == 0)
				break;
		
			if(!(dist in matches))
				continue;
		
			local mlen = matches[dist].len();
			if(mlen<=matchesleft)
			{
				foreach(i,word in matches[dist].slice(0,mlen))
				{
					tbl[m] <- word;
					m += 1;
				}
				matchesleft -= mlen;
			}
			else
			{
				foreach(i,word in matches[dist].slice(0,matchesleft))
				{
					tbl[m] <- word;
					m += 1;
				}
				matchesleft = 0
			}
		}
		return tbl
	}
}

/* @authors rhino
 *
 * @description Get the best match of a word using a lookup table with a filter, if it exist 
 *
 * @param word <string>: Word to use as source
 * @param lookuptbl <table>: Lookup table with target words as keys, uses maximum of SCL_LOOKUP_LIMIT amount of keys
 * @param [lookup_filter <function> = @(key) key]: Filter function to pass lookup table keys before calculations
 * 
 * @return if no valid matches were found: null;
 * 				otherwise: best matched word 
 */
function SpellChecker::Levenshtein::GetBestMatch(word, lookuptbl, lookup_filter = @(key) key)
{
	local matches = ::SpellChecker.Levenshtein(_maxdist,1,_typ).GetBestMatches(word,lookuptbl,lookup_filter);
	return 1 in matches ? matches[1] : null;
}

/* @authors rhino
 *
 * @description Get the best match of a word using a lookup table with a filter, if it exist 
 *
 * @param player <VSLib.Entity>: Player for printing results to
 * @param word <string>: Word to use as source
 * @param lookuptbl <table>: Lookup table with target words as keys, uses maximum of SCL_LOOKUP_LIMIT amount of keys
 * @param [lookup_filter <function> = @(key) key]: Filter function to pass lookup table keys before calculations
 * 
 * @return null
 */
function SpellChecker::Levenshtein::PrintBestMatches(player, word, lookuptbl, lookup_filter = @(key) key)
{	
	local matches = GetBestMatches(word,lookuptbl,lookup_filter)
	local mlen = matches.len();
	if(mlen == 0)
	{
		ClientPrint(player,3,COLOR_DEFAULT+"Unknown "+TXTCLR.OG(_typ)+": "+TXTCLR.OR(word));
		return;
	}
	else if(-1 in matches)
	{
		ClientPrint(player,3,COLOR_DEFAULT+"Unknown "+TXTCLR.OG(_typ)+": "+TXTCLR.OR(word)+". Did you mean"+" "+TXTCLR.BG(matches[matches[-1]])+" ?");
	}
	else if(mlen == 1)
	{
		foreach(dist,w in matches)
		{
			ClientPrint(player,3,COLOR_DEFAULT+"Unknown "+TXTCLR.OG(_typ)+": "+TXTCLR.OR(word)+". Did you mean"+" "+TXTCLR.BG(w)+" ?");
		}
	}
	else
	{	
		ClientPrint(player,3,COLOR_DEFAULT+"Unknown "+TXTCLR.OG(_typ)+": "+TXTCLR.OR(word)+", did you mean one of the below ?")
	
		for(local i=1;i<=mlen;i++)
		{
			ClientPrint(player,3,TXTCLR.OR(i + ". ") + matches[i]);
		}
	} 
}