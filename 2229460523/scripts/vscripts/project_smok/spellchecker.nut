/***************\
* SPELL CHECKER *
\***************/
::SpellChecker <- {}

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
/// [maxdist=3] : Maximum levenshtein distance
/// [maxdisp=5] : Maximum amount of closest word to print
/// [typ="command"] : Type of words
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
function SpellChecker::Levenshtein::GetDistTable(word, lookuptbl)
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
		
		local dist = ::SpellChecker.LevenshteinDist(word,w)
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

function SpellChecker::Levenshtein::GetBestMatches(word, lookuptbl)
{	
	local matches = GetDistTable(word,lookuptbl)
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

function SpellChecker::Levenshtein::GetBestMatch(word, lookuptbl)
{
	local matches = ::SpellChecker.Levenshtein(_maxdist,1,_typ).GetBestMatches(word,lookuptbl);
	return 1 in matches ? matches[1] : null;
}

function SpellChecker::Levenshtein::PrintBestMatches(player, word, lookuptbl)
{	
	local matches = GetBestMatches(word,lookuptbl)
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